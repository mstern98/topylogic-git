from topylogic import *
import topylogic

s = stack()
s.push(1)
s.push("hello")
s.push((2,3,4,2))
print(s.get("a"))
print(s.pop())
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

def v_fun(a : vertex_result):
    print("HI")

def e_fun(a):
    print(a)
    return 1

#vf = topylogic_function(v)
#ef = topylogic_function(e)
g = graph(max_loop=10)
v = vertex(g, v_fun, 0)
print("v: ", v)

print(g.max_loop)
print(g.set_starting_ids([1, 2, 3]))
print(topylogic.SWITCH)

vr = vertex_result((1, 2), 3)
print(vr.get_vertex_argv())
vr.set_edge_argv((2, 3, 4))
print(vr.get_edge_argv())
#v1 = g.create_vertex(vf.callback_void, 1)
#v2 = g.create_vertex(vf.callback_void, 2)
#edge = g.create_edge(v1, v2, ef.callback_int)
#g.set_start_set([1], 1)

#v = vertex_result("hi", "edge")
#print(v1.f)
#print(v1.f(v))

#g.run([v])
