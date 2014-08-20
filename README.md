hdp-ansible
===========

Automated setup for Hortonworks Data Platform cluster

I wanted to learn how to use Hadoop, and there are some great tutorials provided by Hortonworks (a company focused around open source Hadoop development).  Unfortunately my laptop isn't fast enough to run the Hortonworks Sandbox, which is a fairly hefty VM.  In order to participate in the tutorials, I decided to create a small Hadoop cluster on Amazon EC2.  Furthermore, I opted to automate the setup process for consistency and cost savings.  When setup effort becomes negligible there's no problem tearing the infrastructure down when the lesson is complete, which is much cheaper than leaving a multi-instance cluster running at all times.  It also leads to the possiblity of using more powerful servers, allowing faster data analysis and reduced waiting time.

Single-node HDP cluster with Ambari & Hue
-----------------------------------------
 - Provision EC2 instance for Ambari
    - AMI: CentOS 6
    - Type: m3.large or greater
    - Security policy: allow inbound on all TCP & UDP ports (0-65535) plus ICMP echo-reply
 - SSH into machine, run shell script: hdp-single_node-ambari-hue.sh

Initial steps
-------------
 - provision EC2 instance for Ambari (CentOS 6)
 - yum update
 - curl -o ambari.repo http://public-repo-1.hortonworks.com/ambari/centos6/1.x/updates/1.6.1/ambari.repo
 - cp ambari.repo /etc/yum.repos.d
 - yum install ambari-server
 - /etc/init.d/iptables stop
 - ambari-server setup (figure out how to automate)
 - /etc/init.d/iptables start (add iptables exception for port 8080 and any others required)
 - ambari-server start

Ambari agents
-------------
 - provision EC2 instances for each Hadoop master & slave (CentOS 6)
 - yum update
 - yum install ntp
 - curl -o ambari.repo http://public-repo-1.hortonworks.com/ambari/centos6/1.x/updates/1.6.1/ambari.repo && cp ambari.repo /etc/yum.repos.d && yum install ambari-agent
 - sed -i "s/hostname=localhost/hostname=${SERVER_URL}/" /etc/ambari-agent/conf/ambari-agent.ini
 - ambari-agent start
 - chkconfig --level 2345 ntpd on
 - service ntpd start
 - service iptables stop (fix this)

Proceed with Ambari web setup (port 8080) from here...
