# cython: c_string_type=str, c_string_encoding=ascii, embedsignature=True, linetrace=True
# distutils: define_macros=CYTHON_TRACE_NOGIL=1

from __future__ import print_function
from .query_env cimport *

from .types cimport DOCID_T
from libcpp.string cimport string

from cython.operator cimport dereference as deref, preincrement as inc
from ..eval.rankedlist import TRECResult

cdef class PyQueryEnvironment:

    cdef QueryEnvironment *_thisptr

    def __cinit__(PyQueryEnvironment self):
        self._thisptr = NULL

    def __init__(PyQueryEnvironment self):
        self._thisptr = new QueryEnvironment()

    def __dealloc__(PyQueryEnvironment self):
        if self._thisptr != NULL:
            del self._thisptr

    cdef int _check_alive(PyQueryEnvironment self) except -1:
        if self._thisptr == NULL:
            raise RuntimeError("Wrapped C++ object is deleted")
        else:
            return 0

    def add_server(PyQueryEnvironment self, str server_name):
        self._check_alive()
        return self._thisptr.addServer(server_name)

    def add_index(PyQueryEnvironment self, str index_name):
        self._check_alive()
        try:
            self._thisptr.addIndex(index_name)
        except RuntimeError as e :
            raise RuntimeError("Unable to add index. Check index path", e)

    def remove_server(PyQueryEnvironment self, str server_name):
        self._check_alive()
        self._thisptr.removeServer(server_name)

    def remove_index(PyQueryEnvironment self, str index):
        self._check_alive()
        self._thisptr.removeIndex(index)

    def close(PyQueryEnvironment self):
        self._check_alive()
        self._thisptr.close()

    def document_name(PyQueryEnvironment self, int docid):
        self._check_alive()
        return self._thisptr.documentMetadata([docid], "docno")[0]


    def get_documentids(PyQueryEnvironment self, vector[string] document_names):
        self._check_alive()
        return self._thisptr.documentIDsFromMetadata("docno", document_names)

    def document_metadata(PyQueryEnvironment self, int docid, str field_name):
        self._check_alive()
        return self._thisptr.documentMetadata([docid], field_name)[0]

    def document_count(PyQueryEnvironment self, str term = ''):
        self._check_alive()
        if term == '':
            return self._thisptr.documentCount()
        else:
            return self._thisptr.documentCount(term)

    def document_expression_count(PyQueryEnvironment self, str term, str query_type = 'indri'):
        self._check_alive()
        try:
            return self._thisptr.documentExpressionCount(term, query_type)
        except RuntimeError:
            raise RuntimeError("Couldn't understand this query")

    def document_stem_count(PyQueryEnvironment self, string term):
        self._check_alive()
        return self._thisptr.documentStemCount(term)

    def document_length(PyQueryEnvironment self, long long term):
        self._check_alive()
        return self._thisptr.documentLength(term)

    def document_vectors(PyQueryEnvironment self, vector[DOCID_T] docids):
        self._check_alive()
        cdef vector[DocumentVector*] vecs = self._thisptr.documentVectors(docids)
        cdef vector[DocumentVector*].iterator it = vecs.begin()
        dv = []
        while it != vecs.end():
            doc = PyDocumentVector.init_vector(deref(it))
            inc(it)
            dv.append(doc)
        return dv

    def documents(PyQueryEnvironment self, vector[DOCID_T] docids):
        self._check_alive()
        cdef vector[ParsedDocument*] vecs = self._thisptr.documents(docids)
        cdef vector[ParsedDocument*].iterator it = vecs.begin()
        dv = []
        while it != vecs.end():
            doc = PyParsedDocument.init_vector(deref(it))
            inc(it)
            dv.append(doc)
        return dv


    def run_indri_query(PyQueryEnvironment self,
                        str query,
                        int result_count,
                        vector[DOCID_T] docids = [],
                        vector[string] metadata = []):
        self._check_alive()
        cdef QueryRequest* req = new QueryRequest()
        if len(docids) > 0:
            req.docSet = docids
        req.query = query
        if len(metadata) > 0:
            req.metadata = metadata
        req.resultsRequested = result_count
        req.startNum = 0

        cdef QueryResults vecs = self._thisptr.runQuery(deref(req))
        o = PyIndriResults()
        o.results = vecs.results
        return o



    def run_trec_query(PyQueryEnvironment self, str query, int result_count, str runid='indri', string qid='1'):
        self._check_alive()
        cdef vector[ScoredExtentResult] vecs = self._thisptr.runQuery(query, result_count)
        cdef vector[ScoredExtentResult].iterator it = vecs.begin()
        results = TRECResult(runid)
        rank = 1
        while it != vecs.end():
            results.add_result(qid, self.document_name(deref(it).document), rank, deref(it).score, deref(it).document)
            rank += 1
            inc(it)
        return results

    def expression_count(PyQueryEnvironment self, str term, str query_type='indri'):
        self._check_alive()
        return self._thisptr.expressionCount(term, query_type)

    def stem_count(PyQueryEnvironment self, str term):
        self._check_alive()
        return self._thisptr.stemCount(term)

    def stem_field_count(PyQueryEnvironment self, string term, string field):
        self._check_alive()
        return self._thisptr.stemFieldCount(term, field)

    def stem_term(PyQueryEnvironment self, string term):
        self._check_alive()
        return self._thisptr.stemTerm(term)

    def term_count(PyQueryEnvironment self, string term = ""):
        self._check_alive()
        if term.length() == 0:
            return self._thisptr.termCount()
        else:
            return self._thisptr.termCount(term)

    def term_field_count(PyQueryEnvironment self, string term, string field):
        self._check_alive()
        return self._thisptr.termFieldCount(term, field)

    def term_count_unique(PyQueryEnvironment self):
        self._check_alive()
        return self._thisptr.termCountUnique()

    def set_memory(PyQueryEnvironment self, int size):
        self._check_alive()
        self._thisptr.setMemory(size)

    def set_baseline(PyQueryEnvironment self, string baseline):
        self._check_alive()
        return self._thisptr.setBaseline(baseline)

    def set_single_background_model(PyQueryEnvironment self, bool is_single_background_model):
        self._check_alive()
        return self._thisptr.setSingleBackgroundModel(is_single_background_model)

    def set_max_wildcard_terms(PyQueryEnvironment self, int max_terms):
        self._check_alive()
        return self._thisptr.setMaxWildcardTerms(max_terms)

    def __enter__(PyQueryEnvironment self):
        self._check_alive()
        return self

    def __exit__(PyQueryEnvironment self, exc_tp, exc_val, exc_tb):
        if self._thisptr != NULL:
            del self._thisptr
            self._thisptr = NULL
        return False

cdef class PyDocumentVector:
    cdef DocumentVector*_thisptr

    @staticmethod
    cdef init_vector(DocumentVector*ptr):
        v = PyDocumentVector()
        v._thisptr = ptr
        return v

    def __cinit__(PyDocumentVector self):
        self._thisptr = NULL

    def __init__(PyDocumentVector self):
        self._thisptr = NULL

    cdef int _check_alive(PyDocumentVector self) except -1:
        if self._thisptr == NULL:
            raise RuntimeError("Wrapped C++ object is deleted")
        else:
            return 0

    def __dealloc__(PyDocumentVector self):
        if self._thisptr != NULL:
            del self._thisptr

    def stems(PyDocumentVector self):
        self._check_alive()
        return self._thisptr.stems()

    def positions(PyDocumentVector self):
        self._check_alive()
        return self._thisptr.positions()

    def fields(PyDocumentVector self):
        self._check_alive()
        cdef vector[Field] field_vec
        fields = []
        field_vec = self._thisptr.fields()
        for f in field_vec:
            fields.append((f.name, f.begin, f.end))
        return fields

    def __enter__(PyDocumentVector self):
        self._check_alive()
        return self

    def __exit__(PyDocumentVector self, exc_tp, exc_val, exc_tb):
        if self._thisptr != NULL:
            del self._thisptr
            self._thisptr = NULL  # inform __dealloc__
        return False  # propagate exceptions

cdef class PyIndriResults:
    cdef vector[QueryResult] results

    def results_iterator(PyIndriResults self):
        cdef vector[QueryResult].iterator it = self.results.begin()
        output = []
        while it != self.results.end():
            output.append((deref(it).docid, deref(it).documentName, deref(it).snippet, deref(it).score))
            inc(it)
        return output

cdef class PyParsedDocument:
    cdef ParsedDocument*_thisptr
    @staticmethod
    cdef PyParsedDocument init_vector(ParsedDocument*ptr):
        v = PyParsedDocument()
        v._thisptr = ptr
        return v

    def __cinit__(PyParsedDocument self):
        self._thisptr = NULL

    def __init__(PyParsedDocument self):
        self._thisptr = NULL

    cdef int _check_alive(PyParsedDocument self) except -1:
        if self._thisptr == NULL:
            raise RuntimeError("Wrapped C++ object is deleted")
        else:
            return 0

    def __dealloc__(PyParsedDocument self):
        if self._thisptr != NULL:
            del self._thisptr

    property text:

        def __get__(PyParsedDocument self): self._check_alive(); return self._thisptr.text
        def __set__(PyParsedDocument self, value): self._check_alive(); self._thisptr.text = <char*> value

    property textLength:

        def __get__(PyParsedDocument self): self._check_alive(); return self._thisptr.textLength
        def __set__(PyParsedDocument self, value): self._check_alive(); self._thisptr.textLength = <size_t> value

    property content:

        def __get__(PyParsedDocument self): self._check_alive(); return self._thisptr.content
        def __set__(PyParsedDocument self, value): self._check_alive(); self._thisptr.content = <char*> value

    property contentLength:

        def __get__(PyParsedDocument self): self._check_alive(); return self._thisptr.contentLength
        def __set__(PyParsedDocument self, value): self._check_alive(); self._thisptr.contentLength = <size_t> value

    def get_content(PyParsedDocument self):
        self._check_alive()
        return self._thisptr.getContent()

    def positions(PyParsedDocument self):
        self._check_alive()
        cdef vector[TermExtent] vecs = self._thisptr.positions_py()
        cdef vector[TermExtent].iterator it = vecs.begin()
        results = []
        while it != vecs.end():
            doc = PyTermExtent.init_vector(&deref(it))
            inc(it)
            results.append(doc)
        return results

    def terms(PyParsedDocument self):
        self._check_alive()
        return self._thisptr.terms_py()

    def __enter__(PyParsedDocument self):
        self._check_alive()
        return self

    def __exit__(PyParsedDocument self, exc_tp, exc_val, exc_tb):
        if self._thisptr != NULL:
            del self._thisptr
            self._thisptr = NULL  # inform __dealloc__
        return False  # propagate exceptions

cdef class PyTermExtent:
    cdef TermExtent*_thisptr

    @staticmethod
    cdef PyTermExtent init_vector(TermExtent*ptr):
        v = PyTermExtent()
        v._thisptr = ptr
        return v

    cdef int _check_alive(PyTermExtent self) except -1:
        if self._thisptr == NULL:
            raise RuntimeError("Wrapped C++ object is deleted")
        else:
            return 0

    property begin:
        def __get__(PyTermExtent self): self._check_alive(); return self._thisptr.begin
    property end:
        def __get__(PyTermExtent self): self._check_alive(); return self._thisptr.end

    def __dealloc__(PyTermExtent self):
        if self._thisptr != NULL:
            self._thisptr = NULL

    def __exit__(PyTermExtent self, exc_tp, exc_val, exc_tb):
        if self._thisptr != NULL:
            del self._thisptr
            self._thisptr = NULL  # inform __dealloc__
        return False  # propagate exceptions