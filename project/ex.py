#!/usr/bin/env python

class Three:
	def __init__(self, f, g, i):
		self.pos = f
		self.colli1 = g
		self.colli2 = i

class Two(Three):
	def __init__(self, d, e, f):
		self.obj1 = Three(1,2,d)
		self.obj2 = Three(4,5,e)
		self.obj3 = Three(6,7,f)

class Vector(Two):
   def __init__(self, d, e, f):
      self.state = Two(d,e,f)

def testing (voo):
	r = 0
	if hihi == "touch":
		r = 1
		print('first if')
	#elif (for contact in voo.state if contact.colli2 == "left"): # or contact.colli2=="right"):
		print('second if')
		r = 2
	else:
		r = 3
	print('final')
	print(r)
	
v1 = Vector("table", "left", "right")
v2 = Vector("table", "left", "floor")
v3 = Vector("table", "floor", "floor")
v4 = Vector("right", "floor", "table")

hihi = "touch"

testing(v1)

