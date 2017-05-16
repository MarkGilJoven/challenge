#!/bin/bash
# ******************************************
# Program: LAMP Stack Installation Script
# Developer: Pratik Patil
# Date: 10-04-2015
# Last Updated: 11-01-2016
# ******************************************

if [ "`lsb_release -is`" == "Ubuntu" ] || [ "`lsb_release -is`" == "Debian" ]
then
    apt-get -y install mysql-server mysql-client mysql-workbench libmysqld-dev;
    apt-get -y install apache2 php5 libapache2-mod-php5 php5-mcrypt phpmyadmin;
    chmod 755 -R /var/www/;
    printf "<?php\nheader("Content-Type: text/plain"); echo "Hello, world!\n?>" > /var/www/html/hello.php;
    service apache2 restart;

elif [ "`lsb_release -is`" == "CentOS" ] || [ "`lsb_release -is`" == "RedHat" ]
then
    yum -y install httpd mysql-server mysql-devel php php-mysql php-fpm;
    yum -y install epel-release phpmyadmin rpm-build redhat-rpm-config;
    yum -y install mysql-community-release-el7-5.noarch.rpm proj;
    yum -y install tinyxml libzip mysql-workbench-community;
    chmod 777 -R /var/www/;
    printf "<?php\nheader("Content-Type: text/plain"); echo "Hello, world!\n?>" > /var/www/html/hello.php;
    service mysqld restart;
    service httpd restart;
    chkconfig httpd on;
    chkconfig mysqld on;

else
    echo "Unsupported Operating System";
fi
