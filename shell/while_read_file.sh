#!/usr/bin/ksh
#while_read_file.sh
if [ $# != 1 ]; then
	echo "Usage: `basename $0` <file_name>"
	exit 1
fi

FILE_NAME=$1
while read LINE
do
	echo $LINE
done < $FILE_NAME
