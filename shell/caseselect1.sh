#!/usr/bin/ksh
#caseselect

echo "Please input the nuber:"
read NUM
case $NUM in
	1|2|3|4|5)
	echo "you select $NUM" 
	;;
	*)
	echo "please inpu the number between 1 and 5"
	exit 1;
	;;
esac

