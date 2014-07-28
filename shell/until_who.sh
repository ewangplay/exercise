#!/usr/bin/ksh
#until_who.sh
IS_ROOT=`who | grep saserver`
until [ "$IS_ROOT" ] 
do
	sleep 5
	IS_ROOT=`who | grep saserver`
done

echo "watch it, saserver login"

