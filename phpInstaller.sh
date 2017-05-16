#!/bin/bash

# Check if iam root or else no game 
IAM=`whoami`
if [ "$IAM" != "root" ]
then
  echo "I'm sorry: you must be a root to run this script"
  exit 1
fi

# 1 argument or else no game
if [ $# -ne 3 ]; then
	printf "To use: `basename $0` <Random Number from Jenkins> <Reinstall Lamp> <mysql pass>"
	exit 1
fi

serviceCommand() {
  if service --status-all | grep -Fq ${1}; then
     service ${1} ${2}
  fi
}

# save args and variables
random=$1
reinstall=$2
secret=$3
lamps=apache2,mysql
lampsInstalled="Yes"
errcount=0

#check version of linux/unix
osver="$(cat /etc/os-release | grep '^NAME=' | awk -F"=" '{print $2}')"
lcosver="${osver,,}"

# the directory of the script
directory="$(pwd)"

# the temp directory used, within $directory
work_directory=`mktemp -d "$directory/tmp.$random.XXXXX"`

# check if tmp directory was created
if [[ ! "$work_directory" || ! -d "$work_directory" ]]; then
  echo "Could not create temp directory"
  exit 1
fi

# deletes the temp directory
cleanup() {      
  rm -rf "$work_directory"
  rm -rf `basename $0`
  echo "Deleted temp working directory $work_directory"
}

# register the cleanup function to be called on the EXIT signal
trap cleanup EXIT

#check version of lamp to install
while :
do
	# Print if there is a wrong selection
	if [ "$msgerr" != "" ]
	then
		printf "\n$msgerr\n"
	fi

	if [[ "$lcosver" == null ]]
	then
		printf "The OS version couldn't be found.  Exiting prematurely."
		exit 1
	else 
		printf "Attempting to install Lamp on $osver.\n"
		printf "Updating the $osver system before Lamp installation.\n"
		python -mplatform | grep -qi $osver && apt-get update --assume-yes || yum -y update && yum -y install epel-release
			#Check if lamp-server is installed already or not
			printf "Checking if Lamp is installed already.\n"
			#for i in $(echo $lamps | sed "s/,/ /g")
			for i in ${lamps//,/ }
			do
				testservice=$(serviceCommand $i status 2>&1)
				if [ -n "$testservice" ]
				then
					printf $testservice
					errcount=$((errcount+1))
				fi
			done
			printf "\nCHECK $errcount\n"
			if [[ $errcount > 0 ]]
			then
				printf "Lamp is not yet installed.\n"
				if [[ $reinstall == "true" ]]
				then
					printf "Reinstalling Lamp on $osver.\n"
					printf "Stopping services.\n"
					for i in ${lamps//,/ }
					do
						serviceCommand $i stop
					done
					printf "Uninstalling Lamp.\n"
					python -mplatform | grep -qi $osver && apt-get -y purge apache2 php5-cli apache2-mpm-prefork apache2-utils apache2.2-common libapache2-mod-php5 libapr1 libaprutil1 libdbd-mysql-perl libdbi-perl libapache2-mod-php5 libapr1 libaprutil1 libdbd-mysql-perl libdbi-perl libnet-daemon-perl libplrpc-perl libpq5 mysql-client mysql-common mysql-server php5-common php5-mysql phpmyadmin && sudo apt-get autoremove || yum -y remove httpd httpd-devel httpd-manual httpd-tools mod_auth_kerb mod_auth_mysql mod_auth_pgsql mod_authz_ldap mod_dav_svn mod_dnssd mod_nss mod_perl mod_revocator mod_ssl mod_wsgi php php-cli php-common php-gd php-ldap php-mysql php-odbc php-pdo php-pear php-pecl-apc php-pecl-memcache php-pgsql php-soap php-xml php-xmlrpc 
					printf "Installing Lamp on $osver.\n"
					python -mplatform | grep -qi $lcosver && debconf-set-selections <<< 'mysql-server mysql-server/root_password password $secret' && debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $secret' || mysqladmin -u root password $secret
					python -mplatform | grep -qi $lcosver && apt-get install --assume-yes lamp-server^ || yum -y install httpd mysql-server php php-mysql && chkconfig httpd on && chkconfig httpd on
					printf "Move helloworld.php to /var/www/html .\n"
					mv /tmp/helloworld.php /var/www/html || { printf 'Moving helloworld.php failed.' ; exit 1; }
					printf "Restarting Apache."
					serviceCommand apache2 restart || { printf 'Apache restart failed.' ; exit 1; }
				else
					printf "Installing Lamp on $osver.\n"
					python -mplatform | grep -qi $lcosver && debconf-set-selections <<< 'mysql-server mysql-server/root_password password $secret' && debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $secret' || mysqladmin -u root password $secret
					python -mplatform | grep -qi $lcosver && apt-get install --assume-yes lamp-server^ || yum -y install httpd mysql-server php php-mysql && chkconfig httpd on && chkconfig httpd on
					printf "Move helloworld.php to /var/www/html .\n"
					mv /tmp/helloworld.php /var/www/html || { printf 'Moving helloworld.php failed.' ; exit 1; }
					printf "Restarting Apache."
					serviceCommand apache2 restart || { printf 'Apache restart failed.' ; exit 1; }
				fi
			else
				printf "Lamp is already installed.\n"
			fi
		exit 0
	fi
done
