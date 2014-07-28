#!/usr/bin/python

def max(a,b):
	if(a>b):
		print a
	else:
		print b

x=int(raw_input('Enter the first integer: '))
y=int(raw_input('Enter the second integer: '))
print 'the max integer is: ',max(x,y)
