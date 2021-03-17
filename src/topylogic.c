#include "../include/topylogic.h"
#include "../include/topologic.h"

int edge_f(void *args, void *glbl, const void *const edge_vars_a, const void *const edge_vars_b) {
    int res = 0;
    struct glbl_args *g = (struct glbl_args *) glbl;
    PyObject *py_callback = g->py_callback;
    void *glbl_ = g->glbl;

    PyObject *py_args = PyTuple_New(4);
    PyTuple_SetItem(py_args, 0, args);
    PyTuple_SetItem(py_args, 1, glbl_);
    if (edge_vars_a) PyTuple_SetItem(py_args, 2, (PyObject *) edge_vars_a);
    else PyTuple_SetItem(py_args, 2, Py_None);
    if (edge_vars_b) PyTuple_SetItem(py_args, 3, (PyObject *) edge_vars_b);
    else PyTuple_SetItem(py_args, 3, Py_None);

	PyObject *result = PyObject_CallObject(py_callback, py_args);
    
    Py_DECREF(py_args);
    if (!result) return -1;

    PyArg_Parse(result, "i", &res);
    Py_DECREF(result);
    return res;
}


void vertex_f(struct graph* graph, struct vertex_result* args, void* glbl, void* edge_vars) {
	struct glbl_args *g = (struct glbl_args *) glbl;
	PyObject *py_callback = g->py_callback;
	void *glbl_ = g->glbl;

    PyObject *py_args = PyTuple_New(5);
    PyTuple_SetItem(py_args, 0, PyLong_FromVoidPtr(graph));
    PyTuple_SetItem(py_args, 1, args->vertex_argv);
    PyTuple_SetItem(py_args, 2, args->edge_argv);
    if (glbl) PyTuple_SetItem(py_args, 3, glbl_);
    else PyTuple_SetItem(py_args, 3, Py_None);
    if (edge_vars) PyTuple_SetItem(py_args, 4, edge_vars);
    else PyTuple_SetItem(py_args, 4, Py_None);

	void* res = PyObject_CallFunction(py_callback, "O", py_args);
    Py_DECREF(res);
    Py_DECREF(py_args);
}


void generic_f(void *glbl) {
	struct glbl_args *g = (struct glbl_args*) glbl;
	PyObject *py_callback = g->py_callback;
	void* glbl_ = g->glbl;

	void* res = PyObject_CallObject(py_callback, (PyObject *) glbl_);
    Py_DECREF(res);
}

//TODO


