# cython: c_string_type=str, c_string_encoding=ascii, embedsignature=True, linetrace=True
# distutils: define_macros=CYTHON_TRACE_NOGIL=1

from __future__ import print_function

from libcpp.string cimport string

from .query cimport *

cdef class IndriQuery:
    cdef QueryEnvironment *_thisptr

    def __cinit__(IndriQuery self):
        self._thisptr = NULL

    def __init__(IndriQuery self):
        self._thisptr = new QueryEnvironment()

    def __dealloc__(IndriQuery self):
        if self._thisptr != NULL:
            del self._thisptr

    cdef int _check_alive(IndriQuery self) except -1:
        if self._thisptr == NULL:
            raise RuntimeError("Wrapped C++ object is deleted")
        else:
            return 0

    def add_server(IndriQuery self, str server_name):
        self._check_alive()
        return self._thisptr.addServer(server_name)

    def add_index(IndriQuery self, str index_name):
        self._check_alive()
        try:
            self._thisptr.addIndex(index_name)
        except RuntimeError as e:
            raise RuntimeError("Unable to add index. Check index path", e)

    def remove_server(IndriQuery self, str server_name):
        self._check_alive()
        self._thisptr.removeServer(server_name)

    def remove_index(IndriQuery self, str index):
        self._check_alive()
        self._thisptr.removeIndex(index)

    def close(IndriQuery self):
        self._check_alive()
        self._thisptr.close()

    def document_name(IndriQuery self, int docid):
        self._check_alive()
        return self._thisptr.documentMetadata([docid], "docno")[0]

    def get_documentids(IndriQuery self, vector[string] document_names):
        self._check_alive()
        return self._thisptr.documentIDsFromMetadata("docno", document_names)

    def document_metadata(IndriQuery self, int docid, str field_name):
        self._check_alive()
        return self._thisptr.documentMetadata([docid], field_name)[0]

    def document_count(IndriQuery self, str term = ''):
        self._check_alive()
        if term == '':
            return self._thisptr.documentCount()
        else:
            return self._thisptr.documentCount(term)

    def document_expression_count(IndriQuery self, str term, str query_type = 'indri'):
        self._check_alive()
        try:
            return self._thisptr.documentExpressionCount(term, query_type)
        except RuntimeError:
            raise RuntimeError("Couldn't understand this query")

    def document_stem_count(IndriQuery self, string term):
        self._check_alive()
        return self._thisptr.documentStemCount(term)

    def document_length(IndriQuery self, long long term):
        self._check_alive()
        return self._thisptr.documentLength(term)

    def expression_count(IndriQuery self, str term, str query_type='indri'):
        self._check_alive()
        return self._thisptr.expressionCount(term, query_type)

    def stem_count(IndriQuery self, str term):
        self._check_alive()
        return self._thisptr.stemCount(term)

    def stem_field_count(IndriQuery self, string term, string field):
        self._check_alive()
        return self._thisptr.stemFieldCount(term, field)

    def stem_term(IndriQuery self, string term):
        self._check_alive()
        return self._thisptr.stemTerm(term)

    def term_count(IndriQuery self, string term = ""):
        self._check_alive()
        if term.length() == 0:
            return self._thisptr.termCount()
        else:
            return self._thisptr.termCount(term)

    def term_field_count(IndriQuery self, string term, string field):
        self._check_alive()
        return self._thisptr.termFieldCount(term, field)

    def term_count_unique(IndriQuery self):
        self._check_alive()
        return self._thisptr.termCountUnique()

    def set_memory(IndriQuery self, int size):
        self._check_alive()
        self._thisptr.setMemory(size)

    def set_baseline(IndriQuery self, string baseline):
        self._check_alive()
        return self._thisptr.setBaseline(baseline)

    def set_single_background_model(IndriQuery self, bool is_single_background_model):
        self._check_alive()
        return self._thisptr.setSingleBackgroundModel(is_single_background_model)

    def set_max_wildcard_terms(IndriQuery self, int max_terms):
        self._check_alive()
        return self._thisptr.setMaxWildcardTerms(max_terms)

    def __enter__(IndriQuery self):
        self._check_alive()
        return self

    def __exit__(IndriQuery self, exc_tp, exc_val, exc_tb):
        if self._thisptr != NULL:
            del self._thisptr
            self._thisptr = NULL
        return False
