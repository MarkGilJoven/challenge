#!/bin/bash

# Check if iam root or else no game 
IAM=`whoami`
if [ "$IAM" != "root" ]
then
  echo "I'm sorry: you must be a root to run this script"
  exit 1
fi

# 1 argument or else no game
if [ $# -ne 1 ]; then
	printf "To use: `basename $0` <Random Number from Jenkins>"
	exit 1
fi

# save args
random=$1

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

	if [ $lcosver != null ]
	then
		printf "This server is $osver.\n"
		printf "DEBUG---$lcosver---DEBUG"
		if [ $lcosver == *"ubuntu"* ] 
		then
			printf "Attempting to install Lamp on $osver."
			apt-get update
			apt-get install lamp-server^
			exit 0
		elif [ $lcosver == *"centos"* ]
		then
			printf "Attempting to install Lamp."
			exit 0
		else
			printf "Figuring out how to install this..."
			exit 1
		fi
	elif [ "$lcosver" == null ]
	then
		printf "The OS version couldn't be found.  Exiting prematurely."
		exit 1
	else
		printf "It is assumed that this OS is an Ubuntu server.  Installing..."
		exit 0
	fi

done
