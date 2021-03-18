from topylogic import *
import topylogic

def v_alt(a, b, c, d, e):
    m = mod_vertex_request(a.vertices.find_vertex(1), v_fun, (2,3))
    g.submit_request(topylogic.MOD_VERTEX, m)
    print(b, " ", c, " g_ ", a.state_count, " ", a.max_state_changes, " ", a.max_loop)
    return b, c + 1, d, e

def v_fun(a, b1, b2, c, d):
    m = mod_vertex_request(a.vertices.find_vertex(1), v_alt, (2,3))
    g.submit_request(topylogic.MOD_VERTEX, m)
    print(b1, " ", b2, " g_ ", a.state_count)
    print(a, b1, b2, c, d)
    return b1, b2 + 1, c, d

def e_fun(a, b, c, d):
    return 1, (1,2)

g = graph(max_state_changes=10, max_loop=5, context=topylogic.NONE)
v1 = vertex(g, v_fun, 0, (0,1))
v2 = vertex(g, v_fun, 1, (0,2))
v3 = vertex(g, v_alt, 2, (1, 2))
e1 = edge(v1, v2, e_fun, (0, 0))
e2 = edge(v2, v1, e_fun, (0, 2))
e3 = edge(v3, v1, e_fun, (2, 2))
e4 = edge(v1, v3, e_fun, (10, 10))
vr1 = vertex_result("A", 0)
vr2 = vertex_result("B", 0)
vr3 = vertex_result("C", 10)
g.set_starting_ids([2])
g.run([vr2])
g.destroy()

