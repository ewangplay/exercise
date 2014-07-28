#!/usr/bin/python
#filename: pickleTest.py

#import pickle as p
import cPickle as p

dumpfile = 'dumpfile.data'

data = {'data1':['wang', 'zhang', 'liu'],
		'data2':['Tom', 'Sanji', 'Luff'],
		'data3':['Green', 'blue', 'red']}

f = file(dumpfile, 'w')
p.dump(data, f)
f.close()

del data

f = file(dumpfile)
mydata = p.load(f)
f.close()

print mydata
print 'the first data of mydata is', mydata['data1']
print 'the second data of mydata is', mydata['data2']
print 'the third data of mydata is', mydata['data3']
print 'the first name is', mydata['data1'][0]

