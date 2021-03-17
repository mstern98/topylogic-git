#include "../include/topylogic.h"
#include "../include/topologic.h"

int edge_f(void *args, void *glbl, const void *const edge_vars_a, const void *const edge_vars_b) {
    int res = 0;
    struct glbl_args *g = (struct glbl_args *) glbl;
    PyObject *py_callback = g->py_callback;
		void *glbl_ = g->glbl;

    //Make sure variables are correct and correct typing
    //Make the callback to py_callback happen
    //Rinse and repeat for vertex_f and generic_f
		//
	struct edge_args *edgy = malloc(sizeof(struct edge_args));
	edgy->args = args;
	edgy->glbl = glbl_;
	edgy->edge_vars_a = (void *)edge_vars_a;
	edgy->edge_vars_b = (void *)edge_vars_b;

	PyObject *result = PyObject_CallObject(py_callback, (struct _object *)edgy);

	free(edgy);
	edgy = NULL;

    if (!result) return -1;

    PyArg_Parse(result, "i", &res);
    Py_DECREF(result);

    return res;
}


void vertex_f(struct graph* graph, struct vertex_result* args, void* glbl, void* edge_vars) {
	struct glbl_args *g = (struct glbl_args *) glbl;
	PyObject *py_callback = g->py_callback;
	void *glbl_ = g->glbl;

    //PyObject *py_args = Py_BuildValue("()", glbl_);
    //PyList_Append(py_args, Py_BuildValue("{s:O}", "graph", &graph));

	struct vertex_args *vert = malloc(sizeof(struct vertex_args));
	vert->graph = graph;
	vert->args = args;
	vert-> glbl = glbl_;
	vert->edge_vars = edge_vars;

	void* res = PyObject_CallObject(py_callback, NULL);
    Py_DECREF(res);
}


void generic_f(void *glbl) {
	struct glbl_args *g = (struct glbl_args*) glbl;
	PyObject *py_callback = g->py_callback;
	void* glbl_ = g->glbl;

	void* res = PyObject_CallObject(py_callback, (struct _object*)glbl_);
    Py_DECREF(res);
}

//TODO


