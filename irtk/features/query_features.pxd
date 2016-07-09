from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool

cdef extern from "indri/QueryParserWrapper.hpp" namespace "indri::api":
    cdef cppclass QueryParserWrapper:
        TermExtent(int, int)
        int begin
        int end

