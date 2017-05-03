# cython: c_string_type=str, c_string_encoding=ascii, embedsignature=True, linetrace=True
# distutils: define_macros=CYTHON_TRACE_NOGIL=1
from __future__ import print_function

from .indexer cimport IndriIndexer, IndexParam
from cython.operator cimport dereference as deref

cdef class IndriIndexParam:
    cdef IndexParam *_thisptr

    def __init__(IndriIndexParam self):
        self._thisptr = new IndexParam()

    cdef int _check_alive(IndriIndexParam self) except -1:
        if self._thisptr == NULL:
            raise RuntimeError("Wrapped C++ object is deleted")
        else:
            return 0

    property fields:

        def __get__(IndriIndexParam self): self._check_alive(); return self._thisptr.fields
        def __set__(IndriIndexParam self, value): self._check_alive(); self._thisptr.fields = value


    def __enter__(IndriIndexParam self):
        self._check_alive()
        return self

    def __exit__(IndriIndexParam self, exc_tp, exc_val, exc_tb):
        if self._thisptr != NULL:
            del self._thisptr
            self._thisptr = NULL
        return False

cdef class Indexer:
    cdef IndriIndexer *_thisptr

    def __init__(Indexer self, str index_path, IndriIndexParam param):
        self._thisptr = new IndriIndexer(index_path, deref(param._thisptr))

    def __dealloc__(Indexer self):
        if self._thisptr != NULL:
            del self._thisptr

    cdef int _check_alive(Indexer self) except -1:
        if self._thisptr == NULL:
            raise RuntimeError("Wrapped C++ object is deleted")
        else:
            return 0

    def close(Indexer self):
        return self._thisptr.close()

    def add_file(Indexer self, str file_path, str file_class):
        return self._thisptr.addFile(file_path, file_class)

    def add_folder(Indexer self, str folder_path, str file_class):
        return self._thisptr.addFolder(folder_path, file_class)

    def __enter__(Indexer self):
        self._check_alive()
        return self

    def __exit__(Indexer self, exc_tp, exc_val, exc_tb):
        if self._thisptr != NULL:
            del self._thisptr
            self._thisptr = NULL
        return False
