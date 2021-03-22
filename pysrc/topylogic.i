// SPDX-License-Identifier: MIT WITH bison-exception WITH swig-exception
// Copyright © 2020 Matthew Stern, Benjamin Michalowicz

%module topylogic
%{
#include "../include/topylogic.h"
#include "../include/topologic.h"

int edge_f(int id, void *args, void *glbl, const void *const edge_vars_a, const void *const edge_vars_b) {
    int result = 0;
    PyObject *py_res = NULL;
    struct glbl_args *g = (struct glbl_args *) glbl;
    PyObject *py_callback = g->py_callback;
    void *glbl_ = g->glbl;
    
    PyObject *py_args = PyTuple_New(5);
    PyTuple_SetItem(py_args, 0, Py_BuildValue("i", id));
    PyTuple_SetItem(py_args, 1, Py_BuildValue("O", args));
    PyTuple_SetItem(py_args, 2, Py_BuildValue("O", glbl_));
    if (edge_vars_a) PyTuple_SetItem(py_args, 3, Py_BuildValue("O", ((struct edge_vars *) edge_vars_a)->vars));
    else PyTuple_SetItem(py_args, 3, Py_None);
    if (edge_vars_b) PyTuple_SetItem(py_args, 4, Py_BuildValue("O", ((struct edge_vars *) edge_vars_b)->vars));
    else PyTuple_SetItem(py_args, 4, Py_None);

    PyObject *res = PyObject_CallObject(py_callback, py_args);
    Py_INCREF(py_callback);
    Py_DECREF(py_args);
    if (!result) 
        PyErr_Print();

    py_res = PyTuple_GetItem(res, 0);
    if (PyLong_Check(py_res))
        result = (int) PyLong_AsLong(py_res);
    else if (PyBool_Check(py_res)) 
        if (py_res == Py_True) result = 1;
    g->glbl = PyTuple_GetItem(res, 1);

    return result;
}

void vertex_f(int id, struct graph *graph, struct vertex_result *args, void *glbl, void *edge_vars) {
    struct glbl_args *g = (struct glbl_args *) glbl;
    struct edge_vars *ev = (struct edge_vars *) edge_vars;
    PyObject *py_callback = g->py_callback;
    void *glbl_ = g->glbl;

    PyObject *py_graph = SWIG_NewPointerObj(SWIG_as_voidptr(graph), SWIGTYPE_p_graph, 1);
    
    PyObject *py_args = PyTuple_New(6);
    PyTuple_SetItem(py_args, 0, Py_BuildValue("i", id));
    PyTuple_SetItem(py_args, 1, py_graph);
    PyTuple_SetItem(py_args, 2, Py_BuildValue("O", args->vertex_argv));
    PyTuple_SetItem(py_args, 3, Py_BuildValue("O", args->edge_argv));
    if (glbl) PyTuple_SetItem(py_args, 4, Py_BuildValue("O", glbl_));
    else PyTuple_SetItem(py_args, 4, Py_None);
    if (edge_vars) PyTuple_SetItem(py_args, 5, Py_BuildValue("O", ev->vars));
    else PyTuple_SetItem(py_args, 5, Py_None);

    void *res = PyObject_CallFunction(py_callback, "O", py_args);
    Py_INCREF(py_callback);

    if (!res)
        PyErr_Print();

    args->vertex_argv = PyTuple_GetItem(res, 0);
    args->vertex_size = sizeof(args->vertex_argv);
    args->edge_argv = PyTuple_GetItem(res, 1);
    args->edge_size = sizeof(args->edge_argv);
    g->glbl = PyTuple_GetItem(res, 2);
    ev->vars = PyTuple_GetItem(res, 3);
    Py_DECREF(res);
    Py_DECREF(py_graph);
    Py_DECREF(py_args);
}

void generic_f(void *glbl) {
    struct glbl_args *g = (struct glbl_args*) glbl;
    PyObject *py_callback = g->py_callback;
    void *glbl_ = g->glbl;

    void *res = PyObject_CallObject(py_callback, Py_BuildValue("O", glbl_));
    Py_INCREF(py_callback);

    if (!res)
        PyErr_Print();
    Py_DECREF(res);
}

PyObject *parse_data(PyObject *data) {
    if (PyByteArray_Check(data))
        return PyByteArray_FromStringAndSize(PyByteArray_AsString(data), PyByteArray_Size(data));
    else if (PyBool_Check(data) || PyComplex_Check(data) || PyFloat_Check(data))
        return data;
    else if (PyLong_Check(data))
        return PyLong_FromLong(PyLong_AsLong(data)+1);
    else if (PyList_Check(data))
        return parse_list(data);
    else
        return Py_BuildValue("O", data);
}

PyObject *parse_list(PyObject *arg) {
    int i = 0;
    Py_ssize_t len = PyList_Size(arg);
    PyObject *res = PyList_New(len);
    for (i; i < len; ++i) {
        PyObject *data = PyList_GetItem(arg, i);
        PyList_SetItem(res, i, parse_data(data));
    }
    return res;
}

%}

%inline %{
    enum TOPYLOGIC_TYPES {
        NONE_TYPE=0,
        VERTEX_TYPE=1,
        EDGE_TYPE=2
    };
%}

%include "../include/stack.h"
%extend stack{
    stack() {
        return init_stack();
    }
    ~stack() {}
    void destroy() {
        destroy_stack($self);
    }

    PyObject *get(PyObject *index, enum TOPYLOGIC_TYPES dtype=NONE_TYPE) {
        if(!PyLong_Check(index))
            return Py_None;
        int i = (int) PyLong_AsLong(index);
        PyObject *ret = get($self, i);
        if (!ret) return Py_None;
        if (dtype == VERTEX_TYPE)
             return SWIG_NewPointerObj(SWIG_as_voidptr(ret), SWIGTYPE_p_vertex, 1);
        else if (dtype == EDGE_TYPE)
            return SWIG_NewPointerObj(SWIG_as_voidptr(ret), SWIGTYPE_p_edge, 1);
        return ret;
    }

    PyObject *pop(enum TOPYLOGIC_TYPES dtype=NONE_TYPE) {
        PyObject *ret = pop($self);
        if (!ret) return Py_None;
        if (dtype == VERTEX_TYPE) 
            return SWIG_NewPointerObj(SWIG_as_voidptr(ret), SWIGTYPE_p_vertex, 1);
        else if (dtype == EDGE_TYPE) 
            return SWIG_NewPointerObj(SWIG_as_voidptr(ret), SWIGTYPE_p_edge, 1);
        return ret;
    }

    int push(PyObject *data) {
        if (PyList_Check(data) || PyMapping_Check(data)) 
            push($self, parse_list(data));
        return push($self, data);
    }

    PyObject *to_list(enum TOPYLOGIC_TYPES dtype=NONE_TYPE) {
        int i = 0, l = $self->length;
        void *data = NULL;
        PyObject *list = PyList_New(l);
        for (i; i < l; ++i) {
            data = get($self, i);
            if (dtype == VERTEX_TYPE)
                PyList_SetItem(list, i, SWIG_NewPointerObj(SWIG_as_voidptr(data), SWIGTYPE_p_vertex, 1));
            else if(dtype == EDGE_TYPE)
                PyList_SetItem(list, i, SWIG_NewPointerObj(SWIG_as_voidptr(data), SWIGTYPE_p_edge, 1));
            else
                PyList_SetItem(list, i, data);
        }
        return list;
    }
};

%include "../include/AVL.h"
%extend AVLTree {
    AVLTree() {
        return init_avl();
    }
    ~AVLTree() {}
    void destroy() {
        destroy_avl($self);
    }
    int insert(PyObject *data, PyObject *id) {
        if (!PyLong_Check(id))
            return -1;
        int i = (int) PyLong_AsLong(id);
        if (PyList_Check(data) || PyMapping_Check(data)) 
            insert($self, parse_data(data), i);
        return insert($self, data, i);
    }

    PyObject *remove_ID(PyObject * id, enum TOPYLOGIC_TYPES dtype=NONE_TYPE) {
        if (!PyLong_Check(id))
            return Py_None;
        int i = (int) PyLong_AsLong(id);
        PyObject *ret = remove_ID($self, i);
        if (!ret) return Py_None;
        if (dtype == VERTEX_TYPE)
            return SWIG_NewPointerObj(SWIG_as_voidptr(ret), SWIGTYPE_p_vertex, 1);
        else if (dtype == EDGE_TYPE)
            return SWIG_NewPointerObj(SWIG_as_voidptr(ret), SWIGTYPE_p_edge, 1);
        return ret;
    }

    PyObject *find(PyObject *id, enum TOPYLOGIC_TYPES dtype=NONE_TYPE) {
        if (!PyLong_Check(id))
            return Py_None;
        int i = (int) PyLong_AsLong(id);
        PyObject *ret = find($self, i);
        if (!ret) return Py_None;
        if (dtype == VERTEX_TYPE) 
            return SWIG_NewPointerObj(SWIG_as_voidptr(ret), SWIGTYPE_p_vertex, 1);
        else if (dtype == EDGE_TYPE)
            return SWIG_NewPointerObj(SWIG_as_voidptr(ret), SWIGTYPE_p_edge, 1);
        return ret;
    }
    
    PyObject *inorder(enum TOPYLOGIC_TYPES dtype=NONE_TYPE) {
        void *data;
        int i = 0, stack_length = 0;
        PyObject *list;
        struct stack *stack = init_stack();
        inorder($self, stack);
        stack_length = stack->length;
        list = PyList_New(stack_length);
        while ((data = pop(stack)) != NULL) {
            if (dtype == VERTEX_TYPE)
                PyList_SetItem(list, i, SWIG_NewPointerObj(SWIG_as_voidptr(data), SWIGTYPE_p_vertex, 1));
            else if(dtype == EDGE_TYPE)
                PyList_SetItem(list, i, SWIG_NewPointerObj(SWIG_as_voidptr(data), SWIGTYPE_p_edge, 1));
            else
                PyList_SetItem(list, i, data);
            ++i;
        }
        destroy_stack(stack);
        stack = NULL;
        return list;
    }

    PyObject *preorder(enum TOPYLOGIC_TYPES dtype=NONE_TYPE){
        void *data;
        int i = 0, stack_length = 0;
        PyObject *list;
        struct stack *stack = init_stack();
        preorder($self, stack);
        stack_length = stack->length;
        list = PyList_New(stack_length);
        while ((data = pop(stack)) != NULL) {
            if (dtype == VERTEX_TYPE)
                PyList_SetItem(list, i, SWIG_NewPointerObj(SWIG_as_voidptr(data), SWIGTYPE_p_vertex, 1));
            else if(dtype == EDGE_TYPE)
                PyList_SetItem(list, i, SWIG_NewPointerObj(SWIG_as_voidptr(data), SWIGTYPE_p_edge, 1));
            else
                PyList_SetItem(list, i, data);
            ++i;
        }
        destroy_stack(stack);
        stack = NULL;
        return list;
    }

    PyObject *postorder(enum TOPYLOGIC_TYPES dtype=NONE_TYPE){
        void *data;
        int i = 0, stack_length = 0;
        PyObject *list;
        struct stack *stack = init_stack();
        postorder($self, stack);
        stack_length = stack->length;
        list = PyList_New(stack_length);
        while ((data = pop(stack)) != NULL) {
            if (dtype == VERTEX_TYPE)
                PyList_SetItem(list, i, SWIG_NewPointerObj(SWIG_as_voidptr(data), SWIGTYPE_p_vertex, 1));
            else if(dtype == EDGE_TYPE)
                PyList_SetItem(list, i, SWIG_NewPointerObj(SWIG_as_voidptr(data), SWIGTYPE_p_edge, 1));
            else
                PyList_SetItem(list, i, data);
            ++i;
        }
        destroy_stack(stack);
        stack = NULL;
        return list;
    }

    PyObject *stackify() {
        struct stack *stack = init_stack();
        stackify($self, stack);
        return SWIG_NewPointerObj(SWIG_as_voidptr(stack), SWIGTYPE_p_stack, 1);
    }
};

%include "../include/graph.h"
%include "../include/vertex.h"
%include "../include/edge.h"
%include "../include/context.h"
%include "../include/request.h"
%extend edge {
    edge(struct vertex *a, struct vertex *b, PyObject *f, PyObject *glbl = NULL) {
        if (!PyCallable_Check(f)) return NULL;
        if (glbl && (PyList_Check(glbl) || PyMapping_Check(glbl)))
            glbl = parse_data(glbl);
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = glbl;
        g->py_callback = f;
        return create_edge(a, b, edge_f, g);
    }
    ~edge() {}
    void destroy() {
        remove_edge($self->a, $self->b);
    }

    int modify_edge(PyObject *f = NULL, PyObject *glbl = NULL) {
        if (f && !PyCallable_Check(f)) return -1;
        if (glbl && (PyList_Check(glbl) || PyMapping_Check(glbl)))
            glbl = parse_data(glbl);
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
        if (glbl && (PyList_Check(glbl) || PyMapping_Check(glbl))) 
            glbl = parse_data(glbl);
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = glbl;
        g->py_callback = ((struct glbl_args *) $self->glbl)->py_callback;

        return modify_edge($self->a, $self->b, edge_f, g);
    }
};

%include "../include/topylogic.h"
%extend bi_edge {
    bi_edge(struct vertex *a, struct vertex *b, PyObject *f, PyObject *glbl = NULL) {
        if (!PyCallable_Check(f)) return NULL;
        if (glbl && (PyList_Check(glbl) || PyMapping_Check(glbl)))
            glbl = parse_data(glbl);
        
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
    ~bi_edge() {}
    void destroy() {
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
        if (f != NULL && !PyCallable_Check(f)) return -1;
        if (glbl && (PyList_Check(glbl) || PyMapping_Check(glbl)))
            glbl = parse_data(glbl);
        
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
        if (glbl && (PyList_Check(glbl) || PyMapping_Check(glbl))) 
            glbl = parse_data(glbl);

        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = glbl;
        g->py_callback = ((struct glbl_args *) $self->edge_a_to_b->glbl)->py_callback;
        return modify_bi_edge($self->edge_a_to_b->a, $self->edge_a_to_b->b, edge_f, g);;
    }
};

%extend vertex {
    vertex(struct graph *graph, PyObject *f, int id, PyObject *glbl = NULL) {
        if (!PyCallable_Check(f)) return NULL;
        if (glbl && (PyList_Check(glbl) || PyMapping_Check(glbl)))
            glbl = parse_data(glbl);

        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = (void*)glbl;
        g->py_callback = f;
        struct vertex *v = create_vertex(graph, vertex_f, id, g);

        if(!v) return NULL;
        v->graph = graph;
        
        struct edge_vars *vars = (struct edge_vars *) malloc(sizeof(struct edge_vars));
        vars->vars = Py_None;
        modify_shared_edge_vars(v, vars);

        return v;
    }
    ~vertex() {}
    void destroy() {
        struct graph *g = $self->graph;
        $self->graph = NULL;
        ((struct glbl_args *) $self->glbl)->glbl = NULL;
        Py_XDECREF(((struct glbl_args *) $self->glbl)->py_callback);
        ((struct glbl_args *) $self->glbl)->py_callback = NULL;
        remove_vertex(g, $self);
    }
    int modify_vertex(PyObject *f, PyObject *glbl) {
        if (!PyCallable_Check(f)) return -1;
        if (PyList_Check(glbl) || PyMapping_Check(glbl))
            glbl = parse_data(glbl);
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
        if (PyList_Check(glbl) || PyMapping_Check(glbl)) 
            glbl = parse_data(glbl);
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = glbl;
        g->py_callback = ((struct glbl_args *) $self->glbl)->py_callback;
        return modify_vertex($self, vertex_f, g);
    }
    int modify_shared_edge_vars(PyObject *edge_vars) {
        if (PyList_Check(edge_vars) || PyMapping_Check(edge_vars)) 
            edge_vars = parse_data(edge_vars);
        struct edge_vars *vars = (struct edge_vars *) malloc(sizeof(struct edge_vars));
        vars->vars = edge_vars;
        return modify_shared_edge_vars($self, vars);
    }
}

%extend vertex_result {
    vertex_result(PyObject *vertex_argv=NULL, PyObject *edge_argv=NULL) {
        if (PyList_Check(vertex_argv) || PyMapping_Check(vertex_argv))
           vertex_argv = parse_data(vertex_argv); 
        if (PyList_Check(edge_argv) || PyMapping_Check(edge_argv)) 
            edge_argv = parse_data(edge_argv);
       
        size_t v_s = sizeof(vertex_argv);
        size_t e_s = sizeof(edge_argv);
        
        struct vertex_result *vr = (struct vertex_result*) malloc(sizeof(struct vertex_result));
        if (!vr) return NULL;

        vr->vertex_argv = vertex_argv; 
        vr->edge_argv = edge_argv;

        vr->vertex_size = v_s;
        vr->edge_size = e_s;

        return vr;
    }
    
    ~vertex_result() {}
    void destroy() {
        if(!$self) return;
        $self->vertex_argv = NULL;
        $self->edge_argv = NULL;
        free($self);
        $self = NULL;
    }
    void set_vertex_argv(PyObject *vertex_argv) {
        if (PyList_Check(vertex_argv) || PyList_Check(vertex_argv)) 
            vertex_argv = parse_data(vertex_argv);
        $self->vertex_size = sizeof(vertex_argv);
        $self->vertex_argv = vertex_argv;
    }

    void set_edge_argv(PyObject *edge_argv) {
        if (PyList_Check(edge_argv) || PyMapping_Check(edge_argv)) 
            edge_argv = parse_data(edge_argv);
        $self->edge_size = sizeof(edge_argv);
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
        enum MEM_OPTION mem_option = CONTINUE,
        enum REQUEST_FLAG request_flag = IGNORE_FAIL_REQUEST) {
            return graph_init(max_state_changes, snapshot_timestamp, max_loop, lvl_verbose, context, mem_option, request_flag);
        }
    
    ~graph() {}
    void destroy() {
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

    int run(struct vertex_result **init_vertex_args) {
        return run($self, init_vertex_args);
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
        if (f && !PyCallable_Check(f)) return NULL;
        if (glbl && (PyList_Check(glbl) || PyMapping_Check(glbl)))
            glbl = parse_data(glbl);
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
    ~vertex_request() {}
    void destroy() {
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
        if (f && !PyCallable_Check(f)) return NULL;
        if (glbl && (PyList_Check(glbl) || PyMapping_Check(glbl)))
            glbl = parse_data(glbl);
        struct glbl_args *g = (struct glbl_args *) malloc(sizeof(struct glbl_args));
        g->glbl = glbl;
        g->py_callback = f;
        struct mod_vertex_request *v = (struct mod_vertex_request *) malloc(sizeof(struct mod_vertex_request));
        v->vertex = vertex;
        v->f = vertex_f;
        v->glbl = g;
        return v;   
    }
    ~mod_vertex_request() {}
    void destroy() {
        if (!$self) return;
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
        if (PyList_Check(edge_vars) || PyMapping_Check(edge_vars)) 
            edge_vars = parse_data(edge_vars);
        struct mod_edge_vars_request *v = (struct mod_edge_vars_request *) malloc(sizeof(struct mod_edge_vars_request));
        struct edge_vars *vars = (struct edge_vars *) malloc(sizeof(struct edge_vars));
        vars->vars = edge_vars;
        v->vertex = vertex;
        v->edge_vars = vars;
        return v;   
    }
    ~mod_edge_vars_request() {}
    void destroy() {
        $self->vertex = NULL;
        free($self->edge_vars);
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
    ~destroy_vertex_request() {}
    void destroy() {
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
    ~destroy_vertex_id_request() {}
    void destroy() {
        $self->id = 0;
        $self->graph = NULL;
        free($self);
    }
};

%extend edge_request {
    edge_request(struct vertex *a, struct vertex *b, PyObject *f=NULL, PyObject *glbl=NULL) {
        if (f && !PyCallable_Check(f)) return NULL;
        if (glbl && (PyList_Check(glbl) || PyMapping_Check(glbl)))
            glbl = parse_data(glbl);
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
    ~edge_request() {}
    void destroy() {
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
    ~destroy_edge_request() {}
    void destroy() {
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
    ~destroy_edge_id_request() {}
    void destroy() {
        $self->a = NULL;
        $self->id = 0;
        free($self);
    }
};
