cimport cython

from query_env cimport QueryEnvironment
from libcpp.string cimport string

cdef class PyTestClass:
    """
    Cython wrapper class for C++ class TestClass
    """

    cdef:
        QueryEnvironment *_thisptr

    def __cinit__(PyTestClass self):
        # Initialize the "this pointer" to NULL so __dealloc__
        # knows if there is something to deallocate. Do not
        # call new TestClass() here.
        self._thisptr = NULL

    def __init__(PyTestClass self):
        # Constructing the C++ object might raise std::bad_alloc
        # which is automatically converted to a Python MemoryError
        # by Cython. We therefore need to call "new TestClass()" in
        # __init__ instead of __cinit__.
        self._thisptr = new QueryEnvironment()

    def __dealloc__(PyTestClass self):
        # Only call del if the C++ object is alive,
        # or we will get a segfault.
        if self._thisptr != NULL:
            del self._thisptr

    cdef int _check_alive(PyTestClass self) except -1:
        # Beacuse of the context manager protocol, the C++ object
        # might die before PyTestClass self is reclaimed.
        # We therefore need a small utility to check for the
        # availability of self._thisptr
        if self._thisptr == NULL:
            raise RuntimeError("Wrapped C++ object is deleted")
        else:
            return 0


    def setMemory(PyTestClass self, int size):
        self._check_alive()
        self._thisptr.setMemory(size)

    def setBaseline(PyTestClass self, string baseline):
        self._check_alive()
        return self._thisptr.setBaseline(baseline)

    def setSingleBackgroundModel(PyTestClass self, bool isSingleBackgroundModel):
        self._check_alive()
        return self._thisptr.setSingleBackgroundModel(isSingleBackgroundModel)

    def addServer(PyTestClass self, string serverName):
        self._check_alive()
        return self._thisptr.addServer(serverName)

    def addIndex(PyTestClass self, string indexName):
        self._check_alive()
        self._thisptr.addIndex(indexName)

    def removeServer(PyTestClass self, string serverName):
        self._check_alive()
        self._thisptr.removeServer(serverName)

    def removeIndex(PyTestClass self, string indexName):
        self._check_alive()
        self._thisptr.removeIndex(indexName)

    def close(PyTestClass self):
        self._check_alive()
        self._thisptr.close()

    def stemTerm(PyTestClass self, string term):
        self._check_alive()
        return self._thisptr.stemTerm(term)

    def termCountUnique(PyTestClass self):
        self._check_alive()
        return self._thisptr.termCountUnique()

    def termCount(PyTestClass self, string term = ""):
        self._check_alive()
        if term.length() == 0:
            return self._thisptr.termCount()
        else:
            return self._thisptr.termCount(term)

    def close(PyTestClass self, string term):
        self._check_alive()
        return self._thisptr.stemCount(term)

    def close(PyTestClass self, string term, string field):
        self._check_alive()
        return self._thisptr.termFieldCount(term, field)

    def stemFieldCount(PyTestClass self, string term, string field):
        self._check_alive()
        return self._thisptr.stemFieldCount(term, field)

    def expressionCount(PyTestClass self, string term, string field):
        self._check_alive()
        return self._thisptr.expressionCount(term, field)

    def documentExpressionCount(PyTestClass self, string term, string field):
        self._check_alive()
        return self._thisptr.documentExpressionCount(term, field)

    def documentCount(PyTestClass self, string term = ""):
        self._check_alive()
        if term.length() == 0:
            return self._thisptr.documentCount()
        else:
            return self._thisptr.documentCount(term)

    def documentStemCount(PyTestClass self, string term):
        self._check_alive()
        return self._thisptr.documentStemCount(term)

    def setMaxWildcardTerms(PyTestClass self, int maxTerms):
        self._check_alive()
        return self._thisptr.setMaxWildcardTerms(maxTerms)

    # The context manager protocol allows us to precisely
    # control the liftetime of the wrapped C++ object. del
    # is called deterministically and independently of
    # the Python garbage collection.

    def __enter__(PyTestClass self):
        self._check_alive()
        return self

    def __exit__(PyTestClass self, exc_tp, exc_val, exc_tb):
        if self._thisptr != NULL:
            del self._thisptr
            self._thisptr = NULL # inform __dealloc__
        return False # propagate exceptions