// SPDX-License-Identifier: MIT WITH bison-exception WITH swig-exception
// Copyright © 2020 Matthew Stern, Benjamin Michalowicz

%module topylogic
%{
#include "../include/topylogic.h"
#include "../include/topologic.h"

/*PyObject *callback(struct topylogic_function *tf, PyObject *args) {
    if(!tf) return NULL;
    PyObject *arglist;
    arglist = Py_BuildValue("(O)", args);
    PyObject *result = PyEval_CallObject (tf->f, arglist);

    Py_DECREF(arglist);
    if (!result) return NULL;
    return result;
}*/
%}


%include "../include/stack.h"
%extend stack{
    stack() {
        return init_stack();
    }

    ~stack() {
        destroy_stack($self);
    }

    PyObject *get(PyObject *index) {
        if(!PyLong_Check(index))
            return Py_None;
        int i = (int) PyLong_AsLong(index);
        PyObject *ret = get($self, i);
        if (!ret) return Py_None;
        return ret;
    }

    PyObject *pop() {
        PyObject *ret = pop($self);
        if (!ret) return Py_None;
        return ret;
    }

    int push(PyObject *data) {
        return push($self, data);
    }
};

%include "../include/AVL.h"
%extend AVLTree {
    AVLTree() {
        return init_avl();
    }
    ~AVLTree() {
        destroy_avl($self);
    }
    int insert(PyObject *data, PyObject *id) {
        if (!PyLong_Check(id))
            return -1;
        int i = (int) PyLong_AsLong(id);
        return insert($self, data, i);
    }

    PyObject *remove_ID(PyObject * id) {
        if (!PyLong_Check(id))
            return Py_None;
        int i = (int) PyLong_AsLong(id);
        PyObject *ret = remove_ID($self, i);
        if (!ret) return Py_None;
        return ret;
    }

    PyObject *find(PyObject *id) {
        if (!PyLong_Check(id))
            return Py_None;
        int i = (int) PyLong_AsLong(id);
        PyObject *ret = find($self, i);
        if (!ret) return Py_None;
        return ret;
    }

    void inorder(struct stack *stack) {
        return inorder($self, stack);
    }

    void preorder(struct stack *stack){
        return preorder($self, stack);
    }

    void postorder(struct stack *stack){
        return postorder($self, stack);
    }

    void stackify(struct stack *stack){
        return stackify($self, stack);
    }
};

%include "../include/graph.h"
%include "../include/vertex.h"
%include "../include/edge.h"
%extend graph {
    graph(int max_state_changes = -1,
        unsigned int snapshot_timestamp = START_STOP,
        unsigned int max_loop = MAX_LOOPS,
        enum VERBOSITY lvl_verbose = VERTICES | EDGES | FUNCTIONS | GLOBALS,
        enum CONTEXT context = SINGLE,
        enum MEM_OPTION mem_option = CONTINUE) {
            return graph_init(max_state_changes, snapshot_timestamp, max_loop, lvl_verbose, context, mem_option);
        }
    
    ~graph() {
        destroy_graph($self);
    }

    %typemap(in) struct vertex_result **{
        $1 = NULL;
        if (!PyList_Check($input)) {
            PyErr_SetString(PyExc_TypeError, "Not A List");
            return NULL;
        }
        int size = PyList_Size($input);
        int i = 0;
        $1 = (struct vertex_result **) malloc(sizeof(struct vertex_result *) * (size + 1));
        for (i = 0; i < size; i++) {
            PyObject *o = PyList_GetItem($input, i);
            void *argp = NULL;
            const int ret = SWIG_ConvertPtr(o, &argp, $*1_descriptor, 0);
            if (!SWIG_IsOK(ret)) {
                free($1);
                SWIG_exception_fail(SWIG_ArgError(ret), "in method '" "$symname" "', argument " "$argnum"" of type '" "$1_type""'");
            }
            $1[i] = (struct vertex_result *) (argp);
        }
        $1[size] = NULL;
    }

    %typemap(freearg) struct vertex_result **{
        free($1);
    }
    
    %typemap(in) int *id{
        $1 = NULL;
        if (!PyList_Check($input)) {
            PyErr_SetString(PyExc_TypeError, "Not A List");
            return NULL;
        }
        int size = PyList_Size($input);
        int i = 0;
        $1 = (int *) malloc(sizeof(int) * (size));
        for (i = 0; i < size; i++) {
            PyObject *o = PyList_GetItem($input, i);
            if (!PyInt_Check(o)) {
                free($1);
                PyErr_SetString(PyExc_TypeError,"list must contain ints");
            	return NULL;
            }
            $1[i] = PyInt_AsLong(o);
        }
    }

    %typemap(freearg) int *id{
        free($1);
    }

    // %typemap(in) void (*)(struct vertex_result *) {
    //     $1 = NULL;
    //     int ret = 0;
    //     if (!(ret = PyCallable_Check($input)))
    //         SWIG_exception_fail(SWIG_ArgError(ret), "in method '" "$symname" "', argument " "$argnum"" of type '" "$1_type""'");
    //     $1 = $input;
    // }
};

%extend vertex_result {
    vertex_result(PyObject *vertex_argv = NULL, PyObject *edge_argv = NULL, int edge_size=0, int vertex_size=0) {
        struct vertex_result *v = malloc(sizeof(struct vertex_result));
        v->vertex_argv = vertex_argv;
        v->edge_argv = edge_argv;
        v->edge_size = edge_size;
        v->vertex_size = vertex_size;
        return v;
    }
    ~vertex_result() {
        free($self);
    }

    void set_vertex_args(PyObject *vertex_argv, int vertex_size=0) {
        $self->vertex_argv = vertex_argv;
        $self->vertex_size = vertex_size;
    }

    void set_edge_args(PyObject *edge_argv, int edge_size=0) {
        $self->edge_argv = edge_argv;
        $self->edge_size = edge_size;
    }

    PyObject *get_vertex_args() {
        return $self->vertex_argv;
    }

    PyObject *get_edge_args() {
        return $self->edge_argv;
    }
};

%extend vertex_request {
    vertex_request(struct graph *graph, int id, void (*f)(struct graph *, struct vertex_result *, void*, void*)=NULL, PyObject *glbl=NULL) {
        struct vertex_request *v = malloc(sizeof(struct vertex_request));
        v->graph = graph;
        v->id = id;
        v->f = f;
        v->glbl = glbl;
        return v;
    }
    ~vertex_request() {
        free($self);
    }
};

%extend mod_vertex_request {
    mod_vertex_request(struct vertex *vertex, void (*f)(struct graph *, struct vertex_result *, void*, void*)=NULL, PyObject *glbl=NULL) {
        struct mod_vertex_request *v = malloc(sizeof(struct mod_vertex_request));
        v->vertex = vertex;
        v->f = f;
        v->glbl = glbl;
        return v;   
    }
    ~mod_vertex_request() {
        free($self);
    }
};

%extend mod_edge_vars_request {
    mod_edge_vars_request(struct vertex *vertex, PyObject *edge_vars=NULL) {
        struct mod_edge_vars_request *v = malloc(sizeof(struct mod_edge_vars_request));
        v->vertex = vertex;
        v->edge_vars = edge_vars;
        return v;   
    }
    ~mod_edge_vars_request() {
        free($self);
    }
};

%extend destroy_vertex_request {
    destroy_vertex_request(struct graph *graph, struct vertex *vertex) {
        struct destroy_vertex_request *v = malloc(sizeof(struct destroy_vertex_request));
        v->vertex = vertex;
        v->graph = graph;
        return v;   
    }
    ~destroy_vertex_request() {
        free($self);
    }
};

%extend destroy_vertex_id_request {
    destroy_vertex_id_request(struct graph *graph, int id) {
        struct destroy_vertex_id_request *v = malloc(sizeof(struct destroy_vertex_id_request));
        v->id = id;
        v->graph = graph;
        return v;   
    }
    ~destroy_vertex_id_request() {
        free($self);
    }
};

%extend edge_request {
    edge_request(struct vertex *a, struct vertex *b, int (*f)(void *, void*, const void* const, const void* const)=NULL, PyObject *glbl=NULL) {
        struct edge_request *e = malloc(sizeof(struct edge_request));
        e->a = a;
        e->b = b;
        e->f = f;
        e->glbl = glbl;
        return e;
    }
    ~edge_request() {
        free($self);
    }
};

%extend destroy_edge_request {
    destroy_edge_request(struct vertex *a, struct vertex *b) {
        struct destroy_edge_request *e = malloc(sizeof(struct destroy_edge_request));
        e->a = a;
        e->b = b;
        return e;
    }
    ~destroy_edge_request() {
        free($self);
    }
};

%extend destroy_edge_id_request {
    destroy_edge_id_request(struct vertex *a, int id) {
        struct destroy_edge_id_request *e = malloc(sizeof(struct destroy_edge_id_request));
        e->a = a;
        e->id = id;
        return e;
    }
    ~destroy_edge_id_request() {
        free($self);
    }
};

