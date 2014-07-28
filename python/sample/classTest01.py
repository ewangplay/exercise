#!/usr/bin/python
#filename: classTest01.py

class Person:
	population = 0

	def __init__(self, name):
		self.name = name
		Person.population += 1

	def __del__(self):
		Person.population -= 1
		if Person.population == 0:
			print 'I am the last one person.'
		else:
			print 'There are %d person present.' %(Person.population)

	def sayHi(self):
		print 'Hello, my name is', self.name


person1 = Person('Tom')
person1.sayHi()

person2 = Person('Mayo')
person2.sayHi()

del person1
del person2



