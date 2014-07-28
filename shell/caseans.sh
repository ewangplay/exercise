#!/usr/bin/ksh
#caseans.sh
echo "Do you wish to proceed?[y/n]"
read ANS
case $ANS in
	y|Y|yes|Yes)
	echo "procedd..."
	;;
	n|N|no|No)
	echo "Exit..."
	exit 0
	;;
	*)
	echo "`basename $0`: unknown response" >&2
	exit 1
	;;
esac

