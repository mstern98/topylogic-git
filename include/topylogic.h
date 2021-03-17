#ifndef __TOPYLOGIC__
#define __TOPYLOGIC__

#include <Python.h>
#include "./topologic.h"

#ifdef __cplusplus
extern "C" {
#endif

struct bi_edge
{
    struct edge *edge_a_to_b;
    struct edge *edge_b_to_a;
};

struct glbl_args
{
    void *glbl;
    PyObject *py_callback;
};

extern int edge_f(void *args, void *glbl, const void *const edge_vars_a, const void *const edge_vars_b);
extern void vertex_f(struct graph *graph, struct vertex_result* args, void* glbl, void* edge_vars);
extern void generic_f(void *glbl);

#ifdef __cplusplus
}
#endif

#endif
