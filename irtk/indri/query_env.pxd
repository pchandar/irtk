from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool
from types cimport DOCID_T

cdef extern from "indri/MetadataPair.hpp" namespace "indri::parse":
    cdef cppclass MetadataPair:
        char* key
        void* value
        int valueLength;

cdef extern from "indri/TermExtent.hpp" namespace "indri::parse":
    cdef cppclass TermExtent:
        TermExtent(int, int)
        int begin
        int end

cdef extern from "indri/greedy_vector" namespace "indri::utility":
    cdef cppclass greedy_vector[_Type]:
        size_t size()
        _Type* iterator
        _Type& reference
        const _Type& const_reference

        greedy_vector()

        size_t size()
        size_t capacity()

        const _Type* begin()
        _Type* begin()

        const _Type* end()
        _Type* end()

        _Type& at( size_t index )
        const _Type& at( size_t index )

        _Type& front()
        const _Type& front()

        _Type& back()
        const _Type& back()

        void clear()

cdef extern from "indri/ParsedDocument.hpp" namespace "indri::api":
    cdef cppclass ParsedDocument:
        char* text
        size_t textLength

        char* content;
        size_t contentLength;

        string getContent()

        vector[char*] terms_py()
        #vector[TagExtent*] tags_py()
        vector[TermExtent] positions_py()
        vector[MetadataPair] metadata_py()

cdef extern from "indri/ScoredExtentResult.hpp" namespace "indri::api":
    cdef cppclass ScoredExtentResult:
        ScoredExtentResult(double, DOCID_T)
        double score
        DOCID_T document
        int begin
        int end
        int number
        int ordinal
        int parentOrdinal

cdef extern from "indri/DocumentVector.hpp" namespace "indri::api::DocumentVector":
    struct Field:
        string name
        int begin
        int end


cdef extern from "indri/DocumentVector.hpp" namespace "indri::api":
    cdef cppclass DocumentVector:
        vector[string] stems()
        vector[int] positions()
        vector[Field] fields()



cdef extern from "indri/QueryEnvironment.hpp" namespace "indri::api":
    cdef cppclass QueryRequest:
        string query
        vector[string] formulators
        vector[string] metadata
        vector[DOCID_T]  docSet
        int resultsRequested
        int startNum


    cdef cppclass QueryResult:
        string snippet
        string documentName
        DOCID_T docid
        double score
        int begin
        int end

    cdef cppclass QueryResults:
       float parseTime
       float executeTime
       float documentsTime
       int estimatedMatches
       vector[QueryResult] results

    cdef cppclass QueryEnvironment:
        QueryEnvironment()  except +

        void addServer(string)
        void addIndex(string) except +RuntimeError
        void close()

        long long documentCount()
        long long documentCount(string)

        double documentExpressionCount(string, string) except +RuntimeError

        long long documentStemCount(string)

        int documentLength(int documentID)

        vector[DocumentVector*] documentVectors(vector[DOCID_T] documentIDs)

        double expressionCount(string, string)
        vector[string] fieldList()

        void removeServer(string)
        void removeIndex(string)


        void setMemory(int)
        void setBaseline(string)
        long long stemFieldCount(string, string)
        string stemTerm(string)
        long long stemCount(string)
        void setScoringRules(vector[string] rules)
        void setStopwords(vector[string] stopwords)
        void setSingleBackgroundModel(bool)
        void setMaxWildcardTerms(int)

        long long termCount()
        long long termCountUnique()
        long long termFieldCount(string, string)

        long long termCount(string)

        #void setFormulationParameters(Parameters &p);

        vector[ScoredExtentResult] expressionList(string, string)
        vector[ScoredExtentResult] runQuery(string, int)
        QueryResults runQuery(QueryRequest)
        vector[DOCID_T] documentIDsFromMetadata(string attributeName, vector[string] attributeValues )
        # vector[ScoredExtentResult] runQuery(string query, vector[long long] documentSet, int resultsRequested,
        #                                     string queryType = "indri")

        vector[ParsedDocument*] documents( vector[DOCID_T] documentIDs )
        #vector[ParsedDocument*] documents( vector[ScoredExtentResult] )

        vector[string] documentMetadata(vector[DOCID_T] documentIDs, string attributeName)
        #vector[string] documentMetadata( vector[ScoredExtentResult] documentIDs, string attributeName )

        #vector[ParsedDocument*] documentsFromMetadata( string attributeName, vector[string] attributeValues )


        #void addIndex( class IndexEnvironment& environment );


        #QueryAnnotation* runAnnotatedQuery( const std::string& query, int resultsRequested, const std::string &queryType = "indri" );
        #QueryAnnotation* runAnnotatedQuery( const std::string& query, const std::vector<lemur::api::DOCID_T>& documentSet, int resultsRequested, const std::string &queryType = "indri" );

        #std::vector<std::string> pathNames( const std::vector<indri::api::ScoredExtentResult>& results );
        #const std::vector<indri::server::QueryServer*>& getServers()
