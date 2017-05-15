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

function testservice {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "error with $1" >&2
    fi
    return $status
}

# save args and variables
random=$1
reinstall=$2
secret=$3
lamps=apache2,mysql-server,php
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
function cleanup {      
  rm -rf "$work_directory"
  rm -rf "`basename $0`"
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
	elif [[ "$lcosver" == *"ubuntu"* ]]
	then
		printf "Attempting to install Lamp on $osver.\n"
		printf "Updating the $osver system before Lamp installation.\n"
		apt-get update
			#Check if lamp-server is installed already or not
			printf "Checking if Lamp is installed already.\n"
			#for i in $(echo $lamps | sed "s/,/ /g")
			for i in ${lamps//,/ }
			do
				# call your procedure/other scripts here below
				#type "$i">/dev/null 2>&1 || { printf >&2 "Lamp requires $i but it's not installed.\n"; errcount="$errcount+1"; }
				command="service "$i" status"
				testservice $command
				 
			done
			if [[ "$errcount" > 0 ]]
			then
				printf "Lamp is not yet installed.\n"
				printf "Installing Lamp on $osver.\n"	
				debconf-set-selections <<< 'mysql-server mysql-server/root_password password $secret'
				debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $secret'
				apt-get install --assume-yes lamp-server^
			else
				printf "$reinstall"
				printf "testing"
			fi
		exit 0
	elif [[ "$lcosver" == *"centos"* ]]
	then
		printf "Attempting to install Lamp on $osver.\n"
		###
		exit 0
	else
		printf "Figuring out hot to install this...\n"
		exit 0
	fi
done
