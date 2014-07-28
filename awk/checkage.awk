#!/usr/bin/awk -f

# check if the age less specific value
{if($2 < AGE)
	print $0
}

