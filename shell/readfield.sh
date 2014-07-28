#!/usr/bin/ksh
#readfield.sh
while read NAME NO
do
	echo "$NAME $NO"
done < records.txt

