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
  	if service --status-all | grep -Fq ${1}; then
     		service ${1} ${2}
  	fi
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
}

uninstallphp() {
printf "$lcosver"
if [[ "$lcosver" == *"ubuntu"* ]]
then
    printf "Uninstalling Lamp on $osver.\n"
    serviceCommand mysql stop;
    serviceCommand apache2 stop;
    apt-get -y purge apache2 mysql-server php libapache2-mod-php php-mcrypt php-mysql && sudo apt-get autoremove 
elif [[ "$lcosver" == *"centos"* ]]
then
    printf "Uninstalling Lamp on $osver.\n"
    serviceCommand mariadb stop;
    serviceCommand httpd stop;
    yum -y remove httpd mariadb-server mariadb php php-mysql
else
    printf "Unsupported Operating System.\n"
fi
}

installphp() {
if [[ "$lcosver" == *"ubuntu"* ]]
then
    printf "Installing Lamp on $osver.\n"
    #install updates first
    apt-get -y update

    #install the lamp stack
    apt-get -y install lamp-server^;

    #finalize
    printf "<?php\nheader(\"Content-Type: text/plain\"); echo \"Hello, world!\"\n?>" > /var/www/html/hello.php;
    chmod 755 -Rf /var/www;
    serviceCommand apache2 restart;
elif [[ "$lcosver" == *"centos"* ]]
then
    printf "Installing Lamp on $osver.\n"
    #install updates first
    yum -y update
 
    #install the lamp stack
    yum -y install httpd mariadb-server mariadb php php-mysql ;

    #finalize
    printf "<?php\nheader(\"Content-Type: text/plain\"); echo \"Hello, world!\"\n?>" > /var/www/html/hello.php;
    chmod 755 -Rf /var/www;
    serviceCommand httpd restart;
    chkconfig httpd on;
    chkconfig mysqld on;
else 
    printf "Unsupported Operating System.\n"
fi
}

# deletes the temp directory
cleanup() {      
  rm -rf "/tmp/`basename $0`"
  printf "Cleanup temp directory.\n"
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
		checkinstallphp
		printf "CHECK-$errcount\n."
		if [[ $errcount > 0 ]]
		then
			printf "Lamp is not yet installed.\n"
                        printf "Attempting to install Lamp on $osver.\n"
                        installphp
			exit 0
		else
			printf "Lamp is already installed.\n"
		fi
	fi
exit 0
done
