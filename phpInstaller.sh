#!/bin/bash
# Check if iam root or else no game 
IAM=`whoami`
if [ "$IAM" != "root" ]
then
  echo "I'm sorry: you must be a root to run this script"
  exit 1
fi

# 1 argument or else no game
if [ $# -ne 2 ]; then
	printf "To use: `basename $0` <Reinstall Lamp> <mysql pass>"
	exit 1
fi

#save args and variables
reinstall=$1
secret=$2

#check version of linux/unix
osver="$(cat /etc/os-release | grep '^NAME=' | awk -F"=" '{print $2}')"
lcosver="${osver,,}"

serviceCommand() {
	if [[$lcosver == *"ubuntu"*]]
	then
  		if service --status-all | grep -Fq ${1}; then
     		service ${1} ${2}
  		fi
	else
		if systemctl -a | grep -Fq ${1}; then
		systemctl ${1} ${2}
		fi
	fi
}

securemysqlpass() {
mysql_secure_installation <<EOF

y
secret
secret
y
y
y
y
EOF
}

uninstallphp() {
if [ "$lcosver" == *"ubuntu"* ] || [ "$lcosver" == *"debian"* ]
then
    serviceCommand mysql stop;
    serviceCommand apache2 stop;
    apt-get -y purge apache2 mysql-server php libapache2-mod-php php-mcrypt php-mysql && sudo apt-get autoremove 
elif [ "$lcosver" == *"centos"* ] || [ "$lcosver" == *"redhat"* ]
then
    serviceCommand mariadb stop;
    serviceCommand httpd stop;
    yum -y remove httpd mariadb-server mariadb php php-mysql
else
    echo "Unsupported Operating System";
fi
}

installphp() {
if [ "$lcosver" == *"ubuntu"* ] || [ "$lcosver" == *"debian"* ]
then
    #install updates first
    apt-get -y update

    #install the lamp stack
    apt-get -y install lamp-server^;

    #harden sql
    securemysqlpass
    
    #finalize
    chmod 755 -R /var/www/;
    printf "<?php\nheadent-Type: text/plain"); echo "Hello, world!"\n?>" > /var/www/html/hello.php;
    serviceCommand apache2 restart;

elif [ "$lcosver" == *"centos"* ] || [ "$lcosver" == *"redhat"* ]
then
    #install updates first
    yum -y update
 
    #install the lamp stack
    yum -y install httpd mariadb-server mariadb php php-mysql ;

    #harden sql
    securemysqlpass

    #finalize
    chmod 755 -R /var/www/;
    printf "<?php\nheader("Content-Type: text/plain"); echo "Hello, world!"\n?>" > /var/www/html/hello.php;
    serviceCommand httpd restart;
    chkconfig httpd on;
    chkconfig mysqld on;
else
    echo "Unsupported Operating System";
fi
}
# the directory of the script
directory="$(pwd)"

# delete the temp directory
cleanup() {      
  rm -rf "/tmp/`basename $0`"
  echo "Deleted temp working directory $work_directory"
}

# register the cleanup function to be called on the EXIT signal
trap cleanup EXIT

while :
do
	if [[ "$lcosver" == null ]]
	then
		printf "The OS version couldn't be found.  Exiting prematurely."
		exit 1
	elif [[ "$reinstall" == "true" ]]
	then
		uninstallphp	
		installphp
	else
		printf "Attempting to install Lamp on $osver.\n"
		installphp
	fi
done

