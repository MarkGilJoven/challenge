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
	printf "To use: `basename $0` <Random Number from Jenkins> <Reinstall Lamp? 0 or 1> <secret mysql password>"
	exit 1
fi

# save args and variables
random=$1
reinstall=$2
secret=$3
lamps=apache2,apache2-bin,apache2-data,apache2-mpm-prefork,libaio1,libapache2-mod-php5,libapr1,libaprutil1,libaprutil1-dbd-sqlite3,libaprutil1-ldap,libdbd-mysql-perl,libdbi-perl,libhtml-template-perl,libmysqlclient18,libterm-readkey-perl,mysql-client-5.5,mysql-client-core-5.5,mysql-common,mysql-server,mysql-server-5.5,mysql-server-core-5.5,php5-cli,php5-common,php5-json,php5-mysql,php5-readline,ssl-cert
lampsInstalled="Yes"
clamps=httpd,mysql-server,php,php-mysql
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
function cleanup {      
  rm -rf "$work_directory"
  rm -rf "/tmp/`basename $0`
  print "Deleted temp working directory $work_directory\n"
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
	elif [[ "$lcosver" == *"ubuntu"* ]]
	then
		printf "Attempting to install Lamp on $osver.\n"
		printf "Updating the $osver system before Lamp installation.\n"
		apt-get update
			#Check if lamp-server is installed already or not
			printf "Checking if Lamp is installed already.\n"
			for i in $(echo $lamps | sed "s/,/ /g")
			do
				# call your procedure/other scripts here below
				type "$i" >/dev/null 2>&1 || { printf >&2 "Lamp requires $i but it's not installed.\n"; errcount=$errcount+1; }
			done
			printf "$errcount"
			if [[ "$errcount" > 0 ]]
			then
				printf "Lamp is not yet installed.\n"
				printf "Installing Lamp on $osver.\n"	
				debconf-set-selections <<< 'mysql-server mysql-server/root_password password $secret'
				debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $secret'
				apt-get install --assume-yes lamp-server^
			elif [[ "$errcount" == 0 ]]
			then
				printf "Lamp is already installed\n"
				printf "$reinstall"
			else
				printf "testing"
			fi
		exit 0
	elif [[ "$lcosver" == *"centos"* ]]
	then
		printf "Attempting to install Lamp on $osver.\n"
		printf "Updating the $osver system before Lamp installation.\n"
		yum -y update
			#Check if lamp-server is installed already or not
			printf "Checking if Lamp is installed already.\n"
			for i in $(echo $clamps | sed "s/,/ /g")
			do 
				type "$i" >/dev/null 2>&1 || { printf >&2 "Lamp requires $i but it's not installed.\n"; errcount=$errcount+1; }
			done
			printf "$errcount"
			if [[ "$errcount" > 0 ]]
			then
				printf "Lamp is not yet installed.\n"
				printf "Installing Lap on $osver.\n"
				
				yum -y install httpd
				yum -y install mysql-server
				yum -y install php php-mysql
		
				#check ip of host
				ipadd="ifconfig eth0 | grep inet | awk '{ print $2 }'"
		
				#set password for root of mysql
				echo  "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$secret');" | mysql -u root

				#Start services
				service httpd start
				service mysqld start


				#Configure to automatically run on boot
				chkconfig httpd on
				chkconfig mysqld on
				###
				exit 0
			elif [[ "$errcount" == 0 ]]
                        then
                                printf "Lamp is already installed\n"
                                printf "$reinstall"
                        else
                                printf "testing"
			fi
	else
		printf "Figuring out hot to install this...\n"
		exit 0
	fi
done
