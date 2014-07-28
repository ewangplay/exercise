#!/usr/bin/python

while True:
	s = raw_input('Enter string: ')
	if s == 'quit':
		print 'bye-bye'
		break
	elif len(s) < 3:
		continue
	print 'The length of the string is valid'

