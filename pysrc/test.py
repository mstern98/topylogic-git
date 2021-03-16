from topylogic import *
import topylogic

s = stack()
s.push(1)
s.push("hello")
print(s.get("a"))
print(s.pop())
print(s.pop())

a = AVLTree()
a.insert(1, 2)
a.insert("hi", 3)
print(a.find(3))
print(a.find(0))
a.preorder(s)

print(s.pop())
print(s.pop())

def v(a : vertex_result):
    print("HI")

def e(a):
    print(a)
    return 1

#vf = topylogic_function(v)
#ef = topylogic_function(e)
#g = graph()
#v1 = g.create_vertex(vf.callback_void, 1)
#v2 = g.create_vertex(vf.callback_void, 2)
#edge = g.create_edge(v1, v2, ef.callback_int)
#g.set_start_set([1], 1)

#v = vertex_result("hi", "edge")
#print(v1.f)
#print(v1.f(v))

#g.run([v])
