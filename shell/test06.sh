#!/usr/bin/ksh
#interactive test
if test -t; then
	echo "on interactive"
else
	echo "not on interactive"
fi

