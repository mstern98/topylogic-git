#include "../include/topylogic.h"
#include "../include/topologic.h"

struct fireable *create_fireable(struct graph* graph, struct vertex* vertex, struct vertex_result* args, enum STATES color, int iloop) {
    topologic_debug("%s;graph %p;vertex %p;vertex_results %p;color %d;iloop %d", "create_fireable", graph, vertex, args, color, iloop);
    struct fireable *fireable = (struct fireable*) malloc(sizeof(struct fireable));
    if (!fireable) return NULL;

    fireable->args = (struct vertex_result*) malloc(sizeof(struct vertex_result));
    if (!fireable->args) {
        topologic_debug("%s;%s;%p", "create_fireable", "failed to malloc", NULL);
        free(fireable);
        fireable = NULL;
    }

    fireable->args->vertex_size = args->vertex_size;
    fireable->args->edge_size = args->edge_size;

    fireable->graph = graph;
    fireable->vertex = vertex;
    fireable->color = color;
    fireable->iloop = iloop;
   
    Py_BEGIN_ALLOW_THREADS
    PyGILState_STATE state = PyGILState_Ensure();
    PyObject *copy_module = PyImport_ImportModule("copy");
    PyObject *copy_dict   = PyModule_GetDict(copy_module);
    PyObject *copy_obj = PyDict_GetItemString(copy_dict, "deepcopy");

    PyObject *vertex_argv = PyObject_CallFunction(copy_obj, "(O)", args->vertex_argv);
    fireable->args->vertex_argv = vertex_argv;
    Py_DECREF(args->vertex_argv);
    PyObject *edge_argv = PyObject_CallFunction(copy_obj, "(O)", args->edge_argv);
    fireable->args->edge_argv = edge_argv;
    Py_DECREF(args->edge_argv);

    Py_DECREF(copy_module);
    Py_DECREF(copy_dict);
    Py_DECREF(copy_obj);

    PyGILState_Release(state);
    Py_END_ALLOW_THREADS

    topologic_debug("%s;%s;%p", "create_fireable", "success", fireable);
    return fireable;
}

int destroy_fireable(struct fireable *fireable) {
    topologic_debug("%s;fireable %p", "destroy_fireable", fireable);
    if (!fireable) {
        topologic_debug("%s;%s;%d", "destroy_fireable", "failed", -1);
        return -1;
    }
    fireable->args = NULL;
    fireable->graph = NULL;
    fireable->vertex = NULL;
    fireable->color = 0;
    fireable->iloop = 0;
    free(fireable);
    fireable = NULL;
    topologic_debug("%s;%s;%d", "destroy_fireable", "success", 0);
    return 0;
}


