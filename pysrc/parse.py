import topylogic
import json

def parse_json(file):
    with open(file) as f:
        data = json.loads(f.read())

    context = topylogic.SINGLE
    mem_option = topylogic.CONTINUE
    request_flag = topylogic.IGNORE_FAIL_REQUEST
    verbosity = topylogic.VERTICES + topylogic.EDGES + topylogic.FUNCTIONS + topylogic.GLOBALS
    max_loop = 100
    snapshot_timestamp = topylogic.START_STOP

    g = data["graph"]
    if "context" in g:
        context = g["context"]
    if "mem_option" in g:
        mem_option = g["mem_option"]
    if "request_flag" in g:
        request_flag = g["request_flag"]
    if "verbosity" in g:
        verbosity = g["verbosity"]
    if "max_loop" in g:
        max_loop = g["max_loop"]
    if "snapshot_timestamp" in g:
        snapshot_timestamp = g["snapshot_timestamp"]

    graph = topylogic.graph(snapshot_timestamp,
                            max_loop,
                            verbosity,
                            context,
                            mem_option,
                            request_flag)
    if "vertices" in g:
        for v in g["vertices"]:
            vertex = topylogic.vertex(graph, v)
    if "edges" in g:
        for e in g["edges"]:
            v1 = graph.vertices.find(e[0], dtype=topylogic.VERTEX_TYPE)
            v2 = graph.vertices.find(e[1], dtype=topylogic.VERTEX_TYPE)
            if (v1 == None or v2 == None):
                print("Invalid vertices [", e[0], "], [", e[1], "]: ", v1, " ", v2)
            e = topylogic.edge(v1, v2)
    if "bi_edges" in g:
        for e in g["bi_edges"]:
            v1 = graph.vertices.find(e[0], dtype=topylogic.VERTEX_TYPE)
            v2 = graph.vertices.find(e[1], dtype=topylogic.VERTEX_TYPE)
            if (v1 == None or v2 == None):
                print("Invalid vertices [", e[0], "], [", e[1], "]: ", v1,   " ", v2)
            e = topylogic.bi_edge(v1, v2)
    return graph



