from libc.stdlib cimport malloc
from libc.stdlib cimport realloc
from libc.stdlib cimport free
from libc.stdlib cimport rand
from libc.stdlib cimport srand
from libc.stdlib cimport RAND_MAX
from libc.stdio cimport printf
from libc.math cimport exp

cimport cython

import numpy as np
cimport numpy as np
np.import_array()

# constants
from numpy import int32 as INT

cdef inline double get_random() nogil:
    """
    Generate a random number between 0 and 1 sampled uniformly.
    """
    return rand() / RAND_MAX

@cython.cdivision(True)
cdef double compute_gini(double count, double left_count, double right_count,
                         int left_pos_count, int right_pos_count) nogil:
    """
    Compute the Gini index of this attribute.
    """
    cdef double weight
    cdef double pos_prob
    cdef double neg_prob

    cdef double index
    cdef double left_weighted_index
    cdef double right_weighted_index

    weight = left_count / count
    pos_prob = left_pos_count / left_count
    neg_prob = 1 - pos_prob
    index = 1 - (pos_prob * pos_prob) - (neg_prob * neg_prob)
    left_weighted_index = weight * index

    weight = right_count / count
    pos_prob = right_pos_count / right_count
    neg_prob = 1 - pos_prob
    index = 1 - (pos_prob * pos_prob) - (neg_prob * neg_prob)
    right_weighted_index = weight * index

    return left_weighted_index + right_weighted_index

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.cdivision(True)
cdef int generate_distribution(double lmbda, double* distribution,
                               double* gini_indices, int n_gini_indices) nogil:
    """
    Generate a probability distribution based on the Gini index values.
    """
    cdef int i
    cdef double normalizing_constant = 0

    cdef double min_gini = 1
    cdef int n_min = 0
    cdef int first_min = -1

    cdef bint deterministic = 0

    # find min and max Gini values
    for i in range(n_gini_indices):
        if gini_indices[i] < min_gini:
            n_min = 1
            first_min = i
            min_gini = gini_indices[i]
        elif gini_indices[i] == min_gini:
            n_min += 1

    # determine if tree is in deterministic mode
    if lmbda < 0 or exp(- lmbda * min_gini / 5) == 0:
        for i in range(n_gini_indices):
            distribution[i] = 0
        distribution[first_min] = 1

    # generate probability distribution over the features
    else:
        for i in range(n_gini_indices):
            distribution[i] = exp(- lmbda * gini_indices[i] / 5)
            normalizing_constant += distribution[i]

        for i in range(n_gini_indices):
            distribution[i] /= normalizing_constant
            # printf('distribution[%d]: %.7f\n', i, distribution[i])

    return 0

@cython.boundscheck(False)
@cython.wraparound(False)
cdef int sample_distribution(double* distribution, int n_distribution) nogil:
    """
    Randomly sample a feature from the probability distribution.
    """
    cdef int i
    cdef double weight = 0

    weight = get_random()
    # printf('initial weight: %.7f\n', weight)

    for i in range(n_distribution):
        if weight < distribution[i]:
            break
        weight -= distribution[i]

    return i

@cython.boundscheck(False)
@cython.wraparound(False)
cdef int* convert_int_ndarray(np.ndarray arr):
    """
    Converts a numpy array into a C int array.
    """
    cdef int n_elem = arr.shape[0]
    cdef int* new_arr = <int *>malloc(n_elem * sizeof(int))

    for i in range(n_elem):
        new_arr[i] = arr[i]

    return new_arr

cdef void set_srand(int random_state) nogil:
    """
    Sets srand given a random state.
    """
    srand(random_state)

    # get rid of garbage first value:
    # https://stackoverflow.com/questions/30430137/first-random-number-is-always-smaller-than-rest
    rand()

cdef void dealloc(Node *node) nogil:
    """
    Recursively free all nodes in the subtree.
    """
    if not node:
        return

    dealloc(node.left)
    dealloc(node.right)

    # free contents of the node
    if node.is_leaf:
        free(node.leaf_samples)
    else:
        if not node.is_left:
            free(node.valid_features)
        free(node.left_counts)
        free(node.left_pos_counts)
        free(node.right_counts)
        free(node.right_pos_counts)
        free(node.left)
        free(node.right)
