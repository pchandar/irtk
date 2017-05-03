from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector


cdef extern from "indri_extras/IndriIndexer.h" namespace "IndriIndexer":
    cdef cppclass IndexParam:
        IndexParam() except +
        long memory
        bool injectURL
        bool storeDocs
        bool normalize
        string stemmerName
        vector[string] stopwords
        vector[string] fields
        vector[string] metadata
        vector[string] metadataForward
        vector[string] metadataBackward

cdef extern from "indri_extras/IndriIndexer.h":
    cdef cppclass IndriIndexer:
        IndriIndexer(string, IndexParam)  except +
        void addFolder(string, string)
        void addFile(string, string)
        void close()
