#include "../include/topylogic.h"
#include "../include/topologic.h"

int edge_f(void *args, void *glbl, const void *const edge_vars_a, const void *const edge_vars_b) {
    struct glbl_args *g = (struct glbl_args *) glbl;
    PyObject *py_callback = g->py_callback;
    void *glbl_ = g->glbl;

    //Make sure variables are correct and correct typing
    //Make the callback to py_callback happen
    //Rinse and repeat for vertex_f and generic_f
		//
		


	void* result = PyObject_CallObject(py_callback, args, glbl_, edge_vars_a, edge_vars_b);

	return result == NULL ? -1 : 0;
}


void vertex_f(struct graph* graph, struct vertex_result* args, void* glbl, void* edge_vars){
	struct glbl_args* g = (struct glbl_args *) glbl;
	PyObject *py_callback = g->py_callback;
	void *glbl_ = g->glbl;
	
	void* res = PyObject_CallObject(py_callback, graph, args, glbl_, edge_vars);
	assert(res!=NULL);
}


void generic_f(void* glbl){
	struct glbl_args *g = (struct glbl_args*) glbl;
	PyObject *py_callback = g->py_callback;
	void* glbl_ = g->glbl;

	void* res = PyObject_CallObject(py_callback, glbl_);

	assert(res!=NULL);
}

//TODO

