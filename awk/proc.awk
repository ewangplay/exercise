#!/usr/bin/awk -f
# first print the header
BEGIN{
	print "Name\tAge\tAddress"
	print "============================================="
}

# lets add the scores of all the students
(total+=$2)

# finally print the total age
END{
	print "Total age:" total
	print "Average age:" total/NR
}

