#!/usr/bin/python

def func_key(a, b=5, c=10):
	print 'a is',a,'and b is',b,'and c is',c

func_key(12,23)
func_key(a=5, c=50)
func_key(b=100, a=13)

