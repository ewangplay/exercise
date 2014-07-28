#!/usr/bin/awk -f

# first set the FS
BEGIN{
	FS=":"
}

{print $1,"\t",$5}


