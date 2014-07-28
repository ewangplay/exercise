#!/usr/bin/ksh
#while_valid_name.sh
echo "Please input you name:"
while read NAME
do
	if [ "$NAME" == "wangxiaohui" ]; then
		echo "Welcome you $NAME"
		exit 0
	else
		echo "Invalid name, try again!"
	fi
done
