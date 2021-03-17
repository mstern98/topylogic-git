#include "../include/topylogic.h"
#include "../include/topologic.h"

int edge_f(void *args, void *glbl, const void *const edge_vars_a, const void *const edge_vars_b) {
    struct glbl_args *g = (struct glbl_args *) glbl;
    PyObject *py_callback = g->py_callback;
    void *glbl2 = g->glbl;

    //Make sure variables are correct and correct typing
    //Make the callback to py_callback happen
    //Rinse and repeat for vertex_f and generic_f

		if(!((PyCFunction)(int)(*)(void*, void* const void* const, const void* const)py_callback(args, glbl2, edge_vars_a, edge_vars_b))) return -1; 
		return 0;
}


void vertex_f(struct graph* graph, struct vertex_result* args, void* glbl, void* edge_vars){
	struct glbl_args* g = (struct glbl_args *) glbl;
	PyObject *pyCallback = g->py_callback;
	void * glbl2 = glbl_args->glbl;
	
	(PyCFunction)(void)(*)(struct graph*, struct vertex_result*, void* glbl, void* edge_vars)pyCallback(graph, args, glbl2, edge_vars);

}


void generic_f(void* glbl){
	struct glbl_args *g = (struct glbl_args*) glbl;
	
	PyObject *pyCallback = g->py_callback;
	void* glbl2 = g->glbl;

	(PyCFunction)(void)(*)(void*)pyCallback(glbl2);


}

//TODO


