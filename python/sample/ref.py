#!/usr/bin/python
#filename: ref.py

list = ['wang', 'zhang', 'song', 'qian']

listptr = list

print 'list is', list
print 'listptr is', listptr

del listptr[0]

print 'list is', list
print 'listptr is', listptr

list.append('liu')

print 'list is', list
print 'listptr is', listptr

listcp = list[:]

del list[-1]

print 'list is', list
print 'listcp is', listcp

