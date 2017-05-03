from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool

cdef extern from "lemur/IndexTypes.hpp" namespace "lemur::api":
    ctypedef int TERMID_T
    ctypedef TERMID_T DOCID_T

cdef extern from "indri/QueryEnvironment.hpp" namespace "indri::api":
    cdef cppclass QueryEnvironment:
        QueryEnvironment()  except +
        void close()

        void addServer(string)
        void removeServer(string)
        void addIndex(string) except +RuntimeError
        void removeIndex(string)

        int documentLength(int documentID)
        long long documentStemCount(string)
        long long documentCount()
        long long documentCount(string)

        double expressionCount(string, string)
        double documentExpressionCount(string, string) except +RuntimeError
        vector[string] fieldList()

        vector[string] documentMetadata(vector[DOCID_T] documentIDs, string attributeName)
        vector[DOCID_T] documentIDsFromMetadata(string attributeName, vector[string] attributeValues )

        void setMemory(int)
        void setBaseline(string)
        void setMaxWildcardTerms(int)
        void setSingleBackgroundModel(bool)
        void setScoringRules(vector[string] rules)
        void setStopwords(vector[string] stopwords)

        long long stemCount(string)
        long long stemFieldCount(string, string)
        string stemTerm(string)

        long long termCount()
        long long termCountUnique()
        long long termFieldCount(string, string)
        long long termCount(string)
