#!/usr/bin/ksh
#ignore_hash.sh

INPUT_FILE="records1.txt"
if [ -s $INPUT_FILE ]; then
	while read LINE
	do
		case $LINE in
			\#*);;
			*)
			echo $LINE
			;;
		esac
	done < $INPUT_FILE
else
	echo "`basename $0`: $INPUT_FILE does not exist or is empty!"
	exit 1
fi

