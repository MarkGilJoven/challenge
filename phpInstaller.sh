#!/bin/bash
checkosver() {
#check version of linux/unix
osver = $(cat /etc/os-release | grep '^NAME=' | awk -F"=" '{print $2}')
}

# the directory of the script
directory="$(pwd)"

# the temp directory used, within $directory
work_directory=`mktemp -d "$directory/tmp"`

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


# downloader of XAMPP installers 
function downloader () {
	if [ "`which wget`" != null ]; then
		wget $file 
	elif [["`which wget`" == null ] && ["`which curl`" != null ]]; then
		curl -O $file
	else
		printf "wget and curl not found."
		exit
	fi
} 

installxamppver() {
case $xamppver in
	1)	printf "Starting to download and install XAMPP 5.6";
		cd $work_directory
		downloader $file
		printf "Changing rights to execute installer";
		chmod +x *run
		sudo ./xampp*run
;;		
	2)	printf "Starting to download and install XAMPP 7.0";
		cd $work_directory
		downloader $file
                printf "Changing rights to execute installer";
                chmod +x *run
		sudo ./xampp*run

;;
	3)	printf "Starting to download and install XAMPP 7.1";
		cd $work_directory
		downloader $file
                printf "Changing rights to execute installer";
                chmod +x *run
		sudo ./xampp*run

;;
	*)
		exit
;;
esac

}

xamppversion() {
	case $xamppver in
                1)	file="https://www.apachefriends.org/xampp-files/5.6.30/xampp-linux-x64-5.6.30-1-installer.run";
			installxamppver "$xamppver" ;;
                2)	file="https://www.apachefriends.org/xampp-files/7.0.16/xampp-linux-x64-7.0.16-0-installer.run";	
			installxamppver "$xamppver" ;;
                3)	file="https://www.apachefriends.org/xampp-files/7.1.2/xampp-linux-x64-7.1.2-0-installer.run";
			installxamppver "$xamppver" ;;
                4) printf "Installation aborted.  Goodbye.\n"; exit 0;;
                *) msgerr="Invalid entry. Select from the numbers 1-4 only"
        esac
}

#check version of xampp to install
while :
do
	# Print if there is a wrong selection
	if [ "$msgerr" != "" ]
	then
		printf "\n$msgerr\n"
	fi

	printf "Select from the following XAMPP Versions: \n
	1) Stable (5.6v)
	2) Version (7.0v)
	3) Latest and greatest (7.1v)
	4) Exit installation\n"
	read xamppver
	#invoke xamppversion function
	xamppversion xamppver
done
