#!/usr/bin/python
#filename: inherit.py

#class define
class SchoolMember:
	totalmember = 0

	def __init__(self, name, age):
		self.name = name
		self.age = age

		SchoolMember.totalmember += 1

	def __del__(self):
		SchoolMember.totalmember -= 1

	def tell(self):
		print 'My name is %s, age is %d' %(self.name, self.age),

	def population(self):
		print 'There are total %d school members' % SchoolMember.totalmember

class Teacher(SchoolMember):
	def __init__(self, name, age, wage):
		SchoolMember.__init__(self, name, age)
		self.wage = wage

	def tell(self):
		SchoolMember.tell(self)
		print 'wage is', self.wage

class Student(SchoolMember):
	def __init__(self, name, age, mark):
		SchoolMember.__init__(self, name, age)
		self.mark = mark

	def tell(self):
		SchoolMember.tell(self)
		print 'mark is', self.mark

# main program
t = Teacher('Tom', 32, 3000)
s = Student('Mayee', 18, 80)

t.tell()
s.tell()

t.population()
s.population()

del t

s.population()

del s

