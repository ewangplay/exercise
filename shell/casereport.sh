#!/usr/bin/ksh
#casereport.sh
echo "           Weekly Report"
echo "which day do you want to run report[Saturday]?"
read WHEN
echo "Validating ${WHEN:="Saturday"}..."
case $WHEN in
	Monday|MONDAY|mon)
	;;
	Sunday|SUNDAY|sun)
	;;
	Saturday|SATURDAY|sat)
	;;
	*)
	echo "This report can only be run on" >&2
	echo "Mondy or Sunday or Saturday." >&2
	exit 1
	;;
esac

echo "Report run on $WHEN"

