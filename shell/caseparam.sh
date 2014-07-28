#!/usr/bin/ksh
#caseparam.sh
if [ $# != 1 ]; then
	echo "`basename $0` [start|stop|help]" >&2
	exit 1
fi

OPT=$1
case $OPT in
	start)
	echo "start process..."
	;;
	stop)
	echo "stop process..."
	;;
	help)
	echo "display help info"
	;;
	*)
	echo "`basename $0` [start|stop|help]" >&2
	exit 1
	;;
esac

