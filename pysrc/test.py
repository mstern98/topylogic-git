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

a.destroy()
s.destroy()

def v_fun(a, b1, b2, c, d):
    i = stack()
    a.vertices.preorder(i)
    m = mod_vertex_request(a.vertices.find_vertex(1), v_fun, (2,3))
    g.submit_request(topylogic.MOD_VERTEX, m)
    print("a: ", a, " b: ", b1, " ", b2, " c: ", c, " d: ", d)
    if (d == None):
        d = 1
    else:
        d += 10
    b2 += 1
    print("done")
    return b1, b2, c, d

def e_fun(a, b, c, d):
    print(a, b, c, d)
    return 1, (1,2)

#vf = topylogic_function(v)
#ef = topylogic_function(e)

g = graph(max_state_changes=5, max_loop=5, context=topylogic.NONE)
v1 = vertex(g, v_fun, 0, (0,1))
v2 = vertex(g, v_fun, 1, (0,2))
e1 = edge(v1, v2, e_fun, (0, 0))
e2 = edge(v2, v1, e_fun, (0, 2))
vr1 = vertex_result((1, 2), 3)
vr2 = vertex_result(("ji", 3), 4)
g.set_starting_ids([0])
g.run([vr1])


#print("v: ", v.test(), v.test())

#print(g.max_loop)
#print(g.set_starting_ids([1, 2, 3]))
#print(topylogic.SWITCH)

#vr = vertex_result((1, 2), 3)
#print(vr.get_vertex_argv())
#vr.set_edge_argv((2, 3, 4))
#print(vr.get_edge_argv())
#v1 = g.create_vertex(vf.callback_void, 1)
#v2 = g.create_vertex(vf.callback_void, 2)
#edge = g.create_edge(v1, v2, ef.callback_int)
#g.set_start_set([1], 1)

#v = vertex_result("hi", "edge")
#print(v1.f)
#print(v1.f(v))

#g.run([v])
