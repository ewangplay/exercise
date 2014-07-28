#!/usr/bin/python
#filename: mySequ.py

employeelist = ['Tom', 'Jason', 'Mayo', 'Makoi', 'Sanji']

print 'item is', employeelist

#indexing operation
print 'item 0 is', employeelist[0]
print 'item 1 is', employeelist[1]
print 'item 2 is', employeelist[2]
print 'item 3 is', employeelist[3]
print 'item -1 is', employeelist[-1]
print 'item -2 is', employeelist[-2]

#slicing operation
print 'item 1 to 3 is', employeelist[1:3]
print 'item 2 to end is', employeelist[2:]
print 'item 1 to -1 is', employeelist[1:-1]
print 'item start to end is', employeelist[:]

#slicing on string
name = 'Tomsan'

print 'name is', name
print 'char 1 to 3 is', name[1:3]
print 'char 2 to end is', name[2:]
print 'char 1 to -1 is', name[1:-1]
print 'char start to end is', name[:]



