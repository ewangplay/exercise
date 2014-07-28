#!/usr/bin/ksh
#if test5
if [ $# -lt 3 ]; then
	echo "The parameters number is less than 3"
	echo "Usage: `basename $0` arg1 arg2 arg3" >&2
	exit 1
fi

echo "arg1" $1
echo "arg2" $2
echo "arg3" $3

exit 0

