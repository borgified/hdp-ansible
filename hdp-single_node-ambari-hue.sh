#!/bin/bash

echo 'Installing default CentOS 6 updates'
yum -q -y update
echo 'Installing basic packages'
yum -q -y install mlocate ntp screen vim

echo 'Installing Ambari from Hortonworks repo (press Enter to accept defaults for all questions)'
curl -o ambari.repo http://public-repo-1.hortonworks.com/ambari/centos6/1.x/updates/1.6.1/ambari.repo
cp ambari.repo /etc/yum.repos.d
yum -q -y install ambari-server

echo 'Stopping firewall (SYSTEM IS OPEN TO WORLD!)'
chkconfig iptables off
/etc/init.d/iptables stop

echo 'Starting ntpd'
chkconfig 2345 ntpd on
/etc/init.d/ntpd start

echo 'Adding internal IP to /etc/hosts'
echo "`ifconfig eth0 | grep 'inet addr' | awk -F: '{print $2}' | awk '{print $1}'` hdpcluster.local" >> /etc/hosts

echo 'Running ambari-server setup (follow prompts, or figure out how to automate)'
ambari-server setup

echo 'Starting Ambari'
ambari-server start

echo -e "\n\n\nProceed with HDP 2.1 installation via Ambari web interface"
echo '  URL: (get public domain name from EC2 console), port 8080'
echo '  u/p: admin / admin'
echo '  Target Hosts: hdpcluster.local'
echo '  SSH key: (upload key chosen during instance creation)'
echo -e "\n\nInstallation takes about 20-30 minutes on m3.large instance\n\n"

read -p 'When installation is complete, press Enter for instructions to prepare HDP for Hue installation...'

echo -e "\n\nConfigure HDP using Ambari to prepare for Hue installation"
echo '  Services > HDFS > Configs'
echo '    General > WebHDFS enabled (checked)'
echo '    Advanced > Block replication: 1'
echo '    Custom core-site.xml > Add Property...'
echo '      Key: hadoop.proxyuser.hue.hosts  Value: *'
echo '      Key: hadoop.proxyuser.hue.groups Value: *'
echo '    Save'
echo '  Services > Hive > Configs'
echo '    Custom hive-site.xml > Add Property...'
echo '      Key: hive.metastore.pre.event.listeners Value: org.apache.hadoop.hive.ql.security.authorization.AuthorizationPreEventListener'
echo '    Save'
echo '  Services > WebHCat > Configs'
echo '    Custom webhcat-site.xml > Add Property...'
echo '      Key: webhcat.proxyuser.hue.hosts  Value: *'
echo '      Key: webhcat.proxyuser.hue.groups Value: *'
echo '    Save'
echo '  Services > Oozie > Configs'
echo '    Custom oozie-site.xml > Add Property...'
echo '      Key: oozie.service.ProxyUserService.proxyuser.hue.hosts  Value: *'
echo '      Key: oozie.service.ProxyUserService.proxyuser.hue.groups Value: *'
echo '    Save'
echo '  Restart all components indicated'
echo '  Services > HDFS > Summary'
echo '    click Name Node, under Components > Name Node, select Stop'
echo ''
read -p 'When HDP prep is complete, press Enter at this prompt to continue Hue installation...'
echo ''
echo 'Installing Hue'
yum -q -y install hue
echo ''
echo 'Re-enable HDFS Name Node in Ambari'
echo '  Services > HDFS > Summary'
echo '    click Name Node, under Components > Name Node, select Start'
echo ''
read -p 'When Name Name is started, press Enter to continue Hue configuration...'
echo ''
echo 'Configuring Hue'
echo '  Enabling web server on port 8888'
sed -i 's/http_port=8000/http_port=8888/' /etc/hue/conf/hue.ini
sed -i 's/enable_server=no/enable_server=yes/' /etc/hue/conf/hue.ini
echo '  Setting timezone'
sed -i 's/time_zone=America\/Los_Angeles/time_zone=America\/New_York/' /etc/hue/conf/hue.ini
echo '  Setting hostname'
sed -i 's/fs_defaultfs=hdfs:\/\/localhost/fs_defaultfs=hdfs:\/\/hdpcluster.local/' /etc/hue/conf/hue.ini
sed -i 's/webhdfs_url=http:\/\/localhost/webhdfs_url=http:\/\/hdpcluster.local/' /etc/hue/conf/hue.ini
sed -i 's/templeton_url="http:\/\/localhost/templeton_url="http:\/\/hdpcluster.local/' /etc/hue/conf/hue.ini
echo ''
echo 'Make any other adjustments to Hue according to the docs: http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.0.5.0/bk_installing_manually_book/content/rpm-chap-hue-5.html'
echo ''
read -p 'When Hue configuration is complete, press Enter to start Hue...'
echo ''
echo 'Starting Hue'
chkconfig hue on
/etc/init.d/hue start
echo 'Log in to Hue as user "hdfs" with password of your choice'

#TODO allow FQDN to change so instance can be shut down http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.0.5.0/bk_using_Ambari_book/content/ambari-chap1-5-4.html
