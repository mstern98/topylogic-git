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
	struct edge_args *edgy = malloc(sizeof(struct edge_args));
	edgy->args = args;
	edgy->glbl = glbl_;
	edgy->edge_vars_a = (void *)edge_vars_a;
	edgy->edge_vars_b = (void *)edge_vars_b;



	void* result = PyObject_CallObject(py_callback, (struct _object *)edgy);

	free(edgy);
	edgy = NULL;


	return result == NULL ? -1 : 0;
}


void vertex_f(struct graph* graph, struct vertex_result* args, void* glbl, void* edge_vars){
	struct glbl_args *g = (struct glbl_args *) glbl;
	PyObject *py_callback = g->py_callback;
	void *glbl_ = g->glbl;
	//
	struct vertex_args *vert = malloc(sizeof(struct vertex_args));
	vert->graph = graph;
	vert->args = args;
	vert-> glbl = glbl_;
	vert->edge_vars = edge_vars;
	
	void* res = PyObject_CallObject(py_callback, (struct _object *)vert);
	assert(res!=NULL);
}


void generic_f(void* glbl){
	struct glbl_args *g = (struct glbl_args*) glbl;
	PyObject *py_callback = g->py_callback;
	void* glbl_ = g->glbl;

	void* res = PyObject_CallObject(py_callback, (struct _object*)glbl_);

	assert(res!=NULL);
}

//TODO


