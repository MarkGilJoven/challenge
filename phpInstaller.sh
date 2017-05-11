#!/bin/bash
checkosver() {
#check version of linux/unix
osver = $(cat /etc/os-release | grep '^NAME=' | awk -F"=" '{print $2}')
}

installxamppver() {

}

xamppversion() {
	case $xamppver in
                1) printf "https://www.apachefriends.org/xampp-files/5.6.30/xampp-linux-x64-5.6.30-1-installer.run" ;;
                2) printf "https://www.apachefriends.org/xampp-files/7.0.16/xampp-linux-x64-7.0.16-0-installer.run" ;;
                3) printf "https://www.apachefriends.org/xampp-files/7.1.2/xampp-linux-x64-7.1.2-0-installer.run" ;;
                4) printf "Installation aborted.  Goodbye.\n"; exit 0;;
                *) msgerr="Invalid entry. Select from the numbers 1-4 only"
        esac
        clear
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
