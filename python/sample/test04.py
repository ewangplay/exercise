#!/usr/bin/python

number = 23
running = True

while running:
	guess = int(raw_input('Enter an integer: '))
	if guess == number:
		print "Congratulation! You guess it!"
		running = False
	elif guess < number:
		print "Guess less!"
	else:
		print "Guess grater!"
else:
	print "whole loop is over!"

print "Down"

