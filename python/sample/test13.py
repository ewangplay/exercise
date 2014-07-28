#!/usr/bin/python

def printMax(x,y):
	'''Print the maximum of the two integers.
	The tow input must be integers.'''

	if x>y:
		print x
	else:
		print y

print printMax.__doc__
printMax(3,5)
help(printMax)

