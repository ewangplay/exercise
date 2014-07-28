#!/usr/bin/ksh
#if test4
if cp test03.sh myfile.bak > /dev/null 2>&1
then
	echo "copy successfully!"
else
	echo "`basename $0` error: could not copy the file!"
fi

