from topylogic import *
import topylogic

'''
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
'''

def v_alt(i, a, b, c, d, e):
    m = mod_vertex_request(a.vertices.find(1, dtype=topylogic.VERTEX_TYPE), v_fun, [2,3])
    g.submit_request(topylogic.MOD_VERTEX, m)
    print("v_alt ", b, " ", c, " g_ ", a.state_count, " ", a.max_state_changes, " ", a.max_loop)
    return b, c, d, e

def v_fun(i, a, b1, b2, c, d):
    m = mod_vertex_request(a.vertices.find(1, dtype=topylogic.VERTEX_TYPE), v_alt, [2,3])
    g.submit_request(topylogic.MOD_VERTEX, m)
    print("v_fund ", a, b1, b2, c, d)
    b2[0] += 1
    c[0] += 2
    return b1, b2, c, d

def e_fun(i, a, b, c, d):
    return True, (1,2)

g = graph(max_state_changes=8, max_loop=5, context=topylogic.SWITCH)
v1 = vertex(g, v_fun, 0, [1, {1:2, "s":[1, 2]}])
v2 = vertex(g, v_fun, 1, [2, {1:2, "s":[1, 2]}])
v3 = vertex(g, v_alt, 2, [1, 2])

e1 = edge(v1, v2, e_fun, (0, 0))
e2 = edge(v2, v1, e_fun, (0, 2))
e3 = edge(v3, v1, e_fun, (2, 2))
e4 = edge(v1, v3, e_fun, (10, 10))
vr1 = vertex_result("A", [0])
vr2 = vertex_result("B", [0])
vr3 = vertex_result("C", [10])
g.set_starting_ids([0, 1, 2])

print("hmm")
#print(g.vertices.stackify().get(0, dtype=topylogic.VERTEX_TYPE))

g.run([vr1, vr2, vr3])
g.destroy()

print(g.vertices)

