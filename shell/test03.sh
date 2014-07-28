#!/usr/bin/ksh
#if test3
if ps -ef | grep "sapmgr" | grep -v grep > /dev/null 2>&1
then
	echo "sapmgr process is running."
else
	echo "sapmgr process is not running."
fi

