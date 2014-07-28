#!/usr/bin/python

add = {
		'wang' : 'beijing',
		'zhang' : 'shanghai',
		'liu' : 'xian',
		'yang' : 'hangzhou',
		'zhao' : 'nanjing'
		}

print 'The length of the add is', len(add)

print 'The address dict is', add

# add one item into the address list
add['cao'] = 'haidian'

print 'Now the address list is', add

# delete the wang's address from list
del add['wang']
print 'Now the address list is', add

for name, address in add.items():
	print name, ':', address

print '\n\n'

names = add.keys()
names.sort()
for name in names:
	print name, ':', add[name]


