#!/usr/bin/ksh
#while_count.sh
COUNTER=0
while [ $COUNTER -lt 5 ] 
do
	COUNTER=`expr $COUNTER + 1`
	echo $COUNTER
done
