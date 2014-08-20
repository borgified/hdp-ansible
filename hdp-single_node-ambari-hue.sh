#!/bin/bash

echo 'Installing default CentOS 6 updates & ntpd'
yum -qy update
yum -qy install ntp

echo 'Installing Ambari from Hortonworks repo'
curl -o ambari.repo http://public-repo-1.hortonworks.com/ambari/centos6/1.x/updates/1.6.1/ambari.repo
cp ambari.repo /etc/yum.repos.d
yum -qy install ambari-server

echo 'Stopping firewall (SYSTEM IS OPEN TO WORLD!)'
chkconfig --level 2345 iptables off
/etc/init.d/iptables stop

echo 'Starting ntpd'
chkconfig --level 2345 ntpd on
/etc/init.d/ntpd start

echo 'Running ambari-server setup (follow prompts, or figure out how to automate)'
ambari-server setup

echo 'Starting Ambari'
ambari-server start

echo 'Installing Hue'
yum -qy install hue

echo 'Follow instructions to configure Hue using Ambari GUI: http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.0.5.0/bk_installing_manually_book/content/rpm-chap-hue.html'
