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

#ifdef __cplusplus
}
#endif

#endif
