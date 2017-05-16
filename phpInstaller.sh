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
lamps="apache2,mysql"
errcount=0
clamps="httpd,mariadb"


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
$secret
$secret
y
y
y
y
EOF
}

checkinstallphp() {
#Check if lamp-server is installed already or not
printf "Checking if Lamp is installed already.\n"
if [[ "$lcosver" == *"ubuntu"* ]]
then
	for i in ${lamps//,/ }
	do
		testservice=$(serviceCommand $i status 2>&1)
		if [ -n "$testservice" ]
		then
			printf $testservice
			errcount=$((errcount+1))
		fi
	done
else
	for i in ${clamps//,/ }
	do
		testservice=$(serviceCommand $i status 2>&1)
		if [ -n "$testservice" ]
		then
			printf $testservice
			errcount=$((errcount+1))
		fi
	done
fi
return $errcount
}

uninstallphp() {
if [ "$lcosver" == *"ubuntu"* ] || [ "$lcosver" == *"debian"* ]
then
    serviceCommand mysql stop;
    serviceCommand apache2 stop;
    apt-get -y purge apache2 mysql-server php libapache2-mod-php php-mcrypt php-mysql && sudo apt-get autoremove 
else
    serviceCommand mariadb stop;
    serviceCommand httpd stop;
    yum -y remove httpd mariadb-server mariadb php php-mysql
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
    printf "<?php\nheader("Content-Type: text/plain"); echo "Hello, world!"\n?>" > /var/www/html/hello.php;
    serviceCommand apache2 restart;
else
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
fi
}
# the directory of the script
directory="$(pwd)"

# delete the temp directory
cleanup() {      
  rm -rf "/tmp/`basename $0`"
  echo "Deleted temp directory.\n"
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
			exit 0
	else
		test="checkinstallphp"
		if [[ test > 0 ]]
		then
			printf "Lamp is not yet installed.\n"
                        printf "Attempting to install Lamp on $osver.\n"
                        installphp
		else
			printf "Lamp is already installed.\n"
			exit 00
		fi
	fi
exit 0
done

