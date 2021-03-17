// SPDX-License-Identifier: MIT WITH bison-exception WITH swig-exception
// Copyright © 2020 Matthew Stern, Benjamin Michalowicz

%module topylogic
%{
#include "../include/topylogic.h"
#include "../include/topologic.h"
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
        if (PyList_Check(data)) return -1;
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
        if (PyList_Check(data)) return -1;

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

    void stackify(struct stack *stack) {
        return stackify($self, stack);
    }
};

%include "../include/graph.h"
%include "../include/vertex.h"
%include "../include/edge.h"
%include "../include/context.h"
%include "../include/request.h"
%extend edge {
    edge(struct vertex *a, struct vertex *b, PyObject *f, PyObject *glbl = NULL) {
        if (PyList_Check(glbl) || !PyCallable_Check(f)) return NULL;
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = glbl;
        g->py_callback = f;
        if(!PyCallable_Check(f)) return NULL;
        return create_edge(a, b, edge_f, g);
    }
    ~edge() {
        remove_edge($self->a, $self->b);
    }
    int modify_edge(PyObject *f = NULL, PyObject *glbl = NULL) {
        if ((glbl && PyList_Check(glbl)) || (f && !PyCallable_Check(f))) return -1;
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        if (f) { 
            g->py_callback = f;
            Py_XDECREF(((struct glbl_args *) $self->glbl)->py_callback);
        }
        else g->py_callback = ((struct glbl_args *) $self->glbl)->py_callback;
        if (glbl) g->glbl = glbl;
        else g->glbl = ((struct glbl_args *) $self->glbl)->glbl;

        return modify_edge($self->a, $self->b, edge_f, g);
    }
    int set_f(PyObject *f) {
        if(!PyCallable_Check(f)) return -1;
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->py_callback = f;
        Py_XDECREF(((struct glbl_args *) $self->glbl)->py_callback);
        g->glbl = ((struct glbl_args *) $self->glbl)->glbl;

        return modify_edge($self->a, $self->b, edge_f, g);
    }
    int set_glbl(PyObject *glbl = NULL) {
        if (PyList_Check(glbl)) return -1;
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = glbl;
        g->py_callback = ((struct glbl_args *) $self->glbl)->py_callback;

        return modify_edge($self->a, $self->b, edge_f, g);
    }
};

%include "../include/topylogic.h"
%extend bi_edge {
    bi_edge(struct vertex *a, struct vertex *b, PyObject *f, PyObject *glbl = NULL) {
        if (PyList_Check(glbl) || !PyCallable_Check(f)) return NULL;
        
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = glbl;
        g->py_callback = f;

        struct bi_edge *bi = (struct bi_edge *) malloc(sizeof(struct edge));
        if (!bi) return NULL;

        struct edge *edge_a_to_b = (struct edge *) malloc(sizeof(struct edge));
        if (!edge_a_to_b) {
            free(bi);
            bi = NULL;
            return NULL;
        }
        struct edge *edge_b_to_a = (struct edge *) malloc(sizeof(struct edge));
        if (!edge_b_to_a) {
            free(bi);
            bi = NULL;
            free(edge_a_to_b);
            edge_a_to_b = NULL;
            return NULL;
        }
        if(!create_bi_edge(a, b, edge_f, g, &edge_b_to_a, &edge_a_to_b)) {
            free(bi);
            bi = NULL;
            free(edge_a_to_b);
            free(edge_b_to_a);
            edge_a_to_b = NULL;
            edge_b_to_a = NULL;
            return NULL;
        }
        
        bi->edge_a_to_b = edge_a_to_b;
        bi->edge_b_to_a = edge_b_to_a;
        return bi;
    }
    ~bi_edge() {
        ((struct glbl_args *) $self->edge_a_to_b->glbl)->glbl = NULL;
        Py_XDECREF(((struct glbl_args *) $self->edge_a_to_b->glbl)->py_callback);
        ((struct glbl_args *) $self->edge_a_to_b->glbl)->py_callback = NULL;
        ((struct glbl_args *) $self->edge_b_to_a->glbl)->glbl = NULL;
        ((struct glbl_args *) $self->edge_b_to_a->glbl)->py_callback = NULL;

        remove_bi_edge($self->edge_a_to_b->a, $self->edge_a_to_b->b);
        $self->edge_a_to_b = NULL;
        $self->edge_b_to_a = NULL;
        free($self);
    }

    int modify_bi_edge(PyObject *f = NULL, PyObject *glbl = NULL) {
        if ((glbl && PyList_Check(glbl)) || (f != NULL && !PyCallable_Check(f))) return -1;
        
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        if (f) {
            g->py_callback = f;
            Py_XDECREF(((struct glbl_args *) $self->edge_a_to_b->glbl)->py_callback);
        }
        else g->py_callback = ((struct glbl_args *) $self->edge_a_to_b->glbl)->py_callback;
        if (glbl) g->glbl = glbl;
        else g->glbl = ((struct glbl_args *) $self->edge_a_to_b->glbl)->glbl;

        return modify_bi_edge($self->edge_a_to_b->a, $self->edge_a_to_b->b, edge_f, g);
    }
    int set_f(PyObject *f) {
        if (!PyCallable_Check(f)) return -1;

        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = ((struct glbl_args *) $self->edge_a_to_b->glbl)->glbl;
        g->py_callback = f;
        Py_XDECREF(((struct glbl_args *) $self->edge_a_to_b->glbl)->py_callback);
        return modify_bi_edge($self->edge_a_to_b->a, $self->edge_a_to_b->b, edge_f, g);
    }
    int set_glbl(PyObject *glbl = NULL) {
        if (PyList_Check(glbl)) return -1;

        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = glbl;
        g->py_callback = ((struct glbl_args *) $self->edge_a_to_b->glbl)->py_callback;
        return modify_bi_edge($self->edge_a_to_b->a, $self->edge_a_to_b->b, edge_f, g);;
    }
};

%extend vertex {
    vertex(struct graph *graph, PyObject *f, int id, PyObject *glbl = NULL) {
        if (PyList_Check(glbl) || !PyCallable_Check(f)) return NULL;

        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = (void*)glbl;
        g->py_callback = f;
        struct vertex *v = create_vertex(graph, vertex_f, id, g);

        if(!v) return NULL;
        v->graph = graph;
        return v;
    }
    ~vertex() {
        struct graph *g = $self->graph;
        $self->graph = NULL;
        ((struct glbl_args *) $self->glbl)->glbl = NULL;
        Py_XDECREF(((struct glbl_args *) $self->glbl)->py_callback);
        ((struct glbl_args *) $self->glbl)->py_callback = NULL;
        remove_vertex(g, $self);
    }
    int modify_vertex(PyObject *f, PyObject *glbl) {
        if (PyList_Check(glbl) || !PyCallable_Check(f)) return -1;
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = glbl;
        g->py_callback = f;
        return modify_vertex($self, vertex_f, g);
    }
    int modify_f(PyObject *f) {
        if (!PyCallable_Check(f)) return -1;
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = ((struct glbl_args *) $self->glbl)->glbl;
        g->py_callback = f;
        return modify_vertex($self, vertex_f, g);
    }
    int modify_glbl(PyObject *glbl) {
        if (PyList_Check(glbl)) return -1;
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = glbl;
        g->py_callback = ((struct glbl_args *) $self->glbl)->py_callback;
        return modify_vertex($self, vertex_f, g);
    }
    int modify_shared_edge_vars(PyObject *edge_vars) {
        if (PyList_Check(edge_vars)) return -1;
        return modify_shared_edge_vars($self, edge_vars);
    }

    void test() {
        ($self->f)($self->graph, NULL, $self->glbl, $self->shared->vertex_data);
    }
}

%extend vertex_result {
    vertex_result(PyObject *vertex_argv, PyObject *edge_argv) {
        if (PyList_Check(vertex_argv) || PyList_Check(edge_argv)) return NULL;
       
        size_t v_s = 1;
        size_t e_s = 1;
        if (PyTuple_Check(vertex_argv))
            v_s = PyTuple_Size(vertex_argv);
        if (PyTuple_Check(edge_argv))
            e_s = PyTuple_Size(edge_argv);
        
        struct vertex_result *vr = (struct vertex_result*) malloc(sizeof(struct vertex_result));
        if (!vr) return NULL;

        vr->vertex_argv = vertex_argv; 
        vr->edge_argv = edge_argv;

        vr->vertex_size = v_s;
        vr->edge_size = e_s;
        return vr;
    }
    
    ~vertex_result() {
        $self->vertex_argv = NULL;
        $self->edge_argv = NULL;
        free($self);
        $self = NULL;
    }
    
    void set_vertex_argv(PyObject *vertex_argv) {
        if (PyList_Check(vertex_argv)) return;
        if (PyTuple_Check(vertex_argv))
            $self->vertex_size = PyTuple_Size(vertex_argv);
        else
            $self->vertex_size = 1;
        $self->vertex_argv = vertex_argv;
    }

    void set_edge_argv(PyObject *edge_argv) {
        if (PyList_Check(edge_argv)) return;
        if (PyTuple_Check(edge_argv))
            $self->vertex_size = PyTuple_Size(edge_argv);
        else
            $self->edge_size = 1;
        $self->edge_argv = edge_argv;
    }

    PyObject *get_vertex_argv() {
        return $self->vertex_argv;
    }

    PyObject *get_edge_argv() {
        return $self->edge_argv;
    }
}

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

    int set_starting_ids(PyObject *id) {
        if (!PyList_Check(id)) return -1;
        int num_vertices = PyList_Size(id), i = 0;
        int ids[num_vertices];
        for (i = 0; i < num_vertices; ++i) {
            PyObject *o = PyList_GetItem(id, i);
            if (!PyInt_Check(o)) return -1;
            ids[i] = PyInt_AsLong(o);
        }
        return start_set($self, ids, num_vertices);
    }

    int run(PyObject *init_vertex_args) {
        if (!PyList_Check(init_vertex_args)) return -1;
        int n = PyList_Size(init_vertex_args), i = 0;
        struct vertex_result **args = (struct vertex_result **) malloc(sizeof(struct vertex_result *) * n);
        for (i = 0; i < n; ++i) {
            PyObject *o = PyList_GetItem(init_vertex_args, i);
            PyArg_Parse(o, "O", &(args[i]));
        }
        return run($self, args);
    }

    int pause_graph() {
        return pause_graph($self);
    }

    int resume_graph() {
        return resume_graph($self);
    }

    int submit_request(enum REQUESTS request_type, void *request) {
        struct request *req = create_request(request_type, request, NULL);
        return submit_request($self, req);
    }

    int submit_generic_request(PyObject *arg, PyObject *f) {
        if (PyList_Check(arg) || !PyCallable_Check(f)) return -1;
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = arg;
        g->py_callback = f;
        struct request *req = create_request(GENERIC, g, generic_f);
        return submit_request($self, req);
    }
    
    int process_requests() {
        return process_requests($self);
    }
};

%extend vertex_request {
    vertex_request(struct graph *graph, int id, PyObject *f=NULL, PyObject *glbl=NULL) {
        if ((glbl && PyList_Check(glbl)) || (f && !PyCallable_Check(f))) return NULL;
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = glbl;
        g->py_callback = f;
        struct vertex_request *v = (struct vertex_request *) malloc(sizeof(struct vertex_request));
        v->graph = graph;
        v->id = id;
        v->f = vertex_f;
        v->glbl = g;
        return v;
    }
    ~vertex_request() {
        $self->graph = NULL;
        $self->id = 0;
        $self->f = NULL;
        ((struct glbl_args *)$self->glbl)->glbl = NULL;
        ((struct glbl_args *)$self->glbl)->py_callback = NULL;
        free($self->glbl);
        $self->glbl = NULL;
        free($self);
    }
};

%extend mod_vertex_request {
    mod_vertex_request(struct vertex *vertex, PyObject *f=NULL, PyObject *glbl=NULL) {
        if ((glbl && PyList_Check(glbl)) || (f && !PyCallable_Check(f))) return NULL;
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = glbl;
        g->py_callback = f;
        struct mod_vertex_request *v = (struct mod_vertex_request *) malloc(sizeof(struct mod_vertex_request));
        v->vertex = vertex;
        v->f = vertex_f;
        v->glbl = g;
        return v;   
    }
    ~mod_vertex_request() {
        $self->vertex = NULL;
        $self->f = NULL;
        ((struct glbl_args *) $self->glbl)->glbl = NULL;
        ((struct glbl_args *) $self->glbl)->py_callback = NULL;
        free($self->glbl);
        $self->glbl = NULL;
        free($self);
    }
};

%extend mod_edge_vars_request {
    mod_edge_vars_request(struct vertex *vertex, PyObject *edge_vars=NULL) {
        if (PyList_Check(edge_vars)) return NULL;
        struct mod_edge_vars_request *v = (struct mod_edge_vars_request *) malloc(sizeof(struct mod_edge_vars_request));
        v->vertex = vertex;
        v->edge_vars = edge_vars;
        return v;   
    }
    ~mod_edge_vars_request() {
        $self->vertex = NULL;
        $self->edge_vars = NULL;
        free($self);
    }
};

%extend destroy_vertex_request {
    destroy_vertex_request(struct graph *graph, struct vertex *vertex) {
        struct destroy_vertex_request *v = (struct destroy_vertex_request *) malloc(sizeof(struct destroy_vertex_request));
        v->vertex = vertex;
        v->graph = graph;
        return v;   
    }
    ~destroy_vertex_request() {
        $self->vertex = NULL;
        $self->graph = NULL;
        free($self);
    }
};

%extend destroy_vertex_id_request {
    destroy_vertex_id_request(struct graph *graph, int id) {
        struct destroy_vertex_id_request *v = (struct destroy_vertex_id_request *) malloc(sizeof(struct destroy_vertex_id_request));
        v->id = id;
        v->graph = graph;
        return v;   
    }
    ~destroy_vertex_id_request() {
        $self->id = 0;
        $self->graph = NULL;
        free($self);
    }
};

%extend edge_request {
    edge_request(struct vertex *a, struct vertex *b, PyObject *f=NULL, PyObject *glbl=NULL) {
        if ((glbl && PyList_Check(glbl)) || (f && !PyCallable_Check(f))) return NULL;
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = glbl;
        g->py_callback = f;
        struct edge_request *e = (struct edge_request *) malloc(sizeof(struct edge_request));
        e->a = a;
        e->b = b;
        e->f = edge_f;
        e->glbl = g;
        return e;
    }
    ~edge_request() {
        $self->a = NULL;
        $self->b = NULL;
        $self->f = NULL;
        ((struct glbl_args *) $self->glbl)->glbl = NULL;
        ((struct glbl_args *) $self->glbl)->py_callback = NULL;
        free($self->glbl);
        $self->glbl = NULL;
        free($self);
    }
};

%extend destroy_edge_request {
    destroy_edge_request(struct vertex *a, struct vertex *b) {
        struct destroy_edge_request *e = (struct destroy_edge_request *) malloc(sizeof(struct destroy_edge_request));
        e->a = a;
        e->b = b;
        return e;
    }
    ~destroy_edge_request() {
        $self->a = NULL;
        $self->b = NULL;
        free($self);
    }
};

%extend destroy_edge_id_request {
    destroy_edge_id_request(struct vertex *a, int id) {
        struct destroy_edge_id_request *e = (struct destroy_edge_id_request *) malloc(sizeof(struct destroy_edge_id_request));
        e->a = a;
        e->id = id;
        return e;
    }
    ~destroy_edge_id_request() {
        $self->a = NULL;
        $self->id = 0;
        free($self);
    }
};
