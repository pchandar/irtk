import libcpp
cdef extern from "lemur/IndexTypes.hpp" namespace "lemur::api":
    ctypedef int TERMID_T
    ctypedef TERMID_T DOCID_T