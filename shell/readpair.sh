#!/usr/bin/ksh
#readpair.sh
while read REC1
do
	read REC2
	echo "This is the first record: $REC1"
	echo "This is the second record: $REC2"
	echo "----------------------------------------"
done < records.txt

