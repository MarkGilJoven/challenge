#!/bin/bash
# Check if iam root or else no game 
IAM=`whoami`
if [ "$IAM" != "root" ]
then
  echo "I'm sorry: you must be a root to run this script"
  exit 1
fi
#check version of linux/unix
osver="$(cat /etc/os-release | grep '^NAME=' | awk -F"=" '{print $2}')"
lcosver="${osver,,}"

if [ "$lcosver" == *"ubuntu"* ] || [ "$lcosver" == *"debian"* ]
then
    apt-get -y install mysql-server mysql-client mysql-workbench libmysqld-dev;
    apt-get -y install apache2 php5 libapache2-mod-php5 php5-mcrypt phpmyadmin;
    chmod 755 -R /var/www/;
    printf "<?php\nheader("Content-Type: text/plain"); echo "Hello, world!"\n?>" > /var/www/html/hello.php;
    service apache2 restart;

elif [ "$lcosver" == *"centos"* ] || [ "$lcosver" == *"redhat"* ]
then
    yum -y install httpd mysql-server mysql-devel php php-mysql php-fpm;
    yum -y install epel-release phpmyadmin rpm-build redhat-rpm-config;
    yum -y install mysql-community-release-el7-5.noarch.rpm proj;
    yum -y install tinyxml libzip mysql-workbench-community;
    chmod 755 -R /var/www/;
    printf "<?php\nheader("Content-Type: text/plain"); echo "Hello, world!"\n?>" > /var/www/html/hello.php;
    service mysqld restart;
    service httpd restart;
    chkconfig httpd on;
    chkconfig mysqld on;

else
    echo "Unsupported Operating System";
fi
