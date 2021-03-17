import ctypes
POINTER = ctypes.POINTER

class _AVLNode(ctypes.Structure): pass
_AVLNode.__fields__ = [
        ('data', ctypes.c_void_p),
        ('id', ctypes.c_int),
        ('height', ctypes.c_int),
        ('left', POINTER(_AVLNode)),
        ('right', POINTER(_AVLNode))
    ]

class _AVLTree(ctypes.Structure):
    __fields__ = [
        ('AVLNode', POINTER(_AVLNode)),
        ('size', ctypes.c_int)
    ]

class _stack_node(ctypes.Structure): pass
_stack_node.__fields__ = [
        ('data', ctypes.c_void_p),
        ('next', POINTER(_stack_node))
    ]

class _stack(ctypes.Structure):
    __fields__ = [
        ('root', POINTER(_stack_node)),
        ('length', ctypes.c_int)
    ]

class _graph(ctypes.Structure):
    __fields__ = [
        ('context', ctypes.c_int),
        ('mem_option', ctypes.c_int),
        ('vertices', POINTER(_AVLTree)),
        ('start', POINTER(_stack)),
        ('modify', POINTER(_stack)),
        ('remove_edges', POINTER(_stack)),
        ('remove_vertices', POINTER(_stack)),
        ('max_state_changes', ctypes.c_int),
        ('max_loop', ctypes.c_int),
        ('snapshot_time', ctypes.c_int),
        ('level_verbose', ctypes.c_uint),
        ('state_count', ctypes.c_int),
        ('__lock', ctypes.c_void_p),
        ('__color_lock', ctypes.c_void_p),
        ('__state', ctypes.c_int),
        ('__previous_color', ctypes.c_int),
        ('__print_flag', ctypes.c_int),
        ('__red_vertex_count', ctypes.c_int),
        ('__black_vertex_count', ctypes.c_int),
        ('__pause', ctypes.c_int),
        ('__red_locked', ctypes.c_int),
        ('__black_locked', ctypes.c_int),
        ('__num_vertices', ctypes.c_int),
        ('__pause_cond', ctypes.c_void_p),
        ('__red_fire', ctypes.c_void_p),
        ('__black_fire', ctypes.c_void_p)
    ]

class _vertex_result(ctypes.Structure):
    __fields__ = [
        ('vertex_argv', ctypes.c_void_p),
        ('vertex_size', ctypes.c_ssize_t),
        ('edge_argv', ctypes.c_void_p),
        ('edge_size', ctypes.c_ssize_t),
    ]
