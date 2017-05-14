#!/bin/bash
# 1 argument or else no game
if [ $# -ne 1 ]; then
	printf "To use: `basename $0` <Random Number from Jenkins>"
	exit 1
fi
# save args
random=$1

#check version of linux/unix
osver="$(cat /etc/os-release | grep '^NAME=' | awk -F"=" '{print $2}')"

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

	if [ "$osver" != "Ubuntu" ]
	then
		printf "This is not an Ubuntu server.  This server is an $osver.  Attempting to install Lamp."
		#
		#
		#
		exit 1
	elif [ "$osver" = null ]
	then
		printf "The OS version couldn't be found.  Exiting prematurely."
		exit 1
	else
		printf "It is assumed that this OS is an Ubuntu server.  Installing..."
		sudo apt-get update
		sudo apt-get install lamp-server^
		exit 0
	fi

	#printf "Select from the following XAMPP Versions: \n
	#1) Stable (5.6v)
	#2) Version (7.0v)
	#3) Latest and greatest (7.1v)
	#4) Exit installation\n"
	#read xamppver
	
done
