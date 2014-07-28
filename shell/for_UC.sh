#!/usr/bin/ksh
#for_UC.sh
for file in `ls for*`
do
	cat $file | tr "[a-z]" "[A-Z]" > $file.UC
done

