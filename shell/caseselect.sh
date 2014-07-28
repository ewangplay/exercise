#!/usr/bin/ksh
#caseselect

echo "Please input the nuber:"
read NUM
case $NUM in
	1)
	echo "you select 1"
	;;
	2)
	echo "you select 2"
	;;
	3)
	echo "you select 3"
	;;
	4)
	echo "you select 4"
	;;
	5)
	echo "you select 5"
	;;
	*)
	echo "please inpu the number between 1 and 5"
	exit 1;
	;;
esac

