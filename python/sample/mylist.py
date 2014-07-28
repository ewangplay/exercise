#!/usr/bin/python
#Filename: mylist.py

mylist = ['apple', 'banana', 'pale', 'orange']

print 'I have', len(mylist), 'fruit.'
print 'There are:'
for item in mylist:
	print item,

print '\nI add one fruit: migua'
mylist.append('migua')
print 'Now my fruit are:', mylist

print 'I sort the fruit.'
mylist.sort()
print 'Now my fruit are:', mylist

print 'I bought the first fruit.'
del mylist[0]
print 'Now my fruit are:', mylist

