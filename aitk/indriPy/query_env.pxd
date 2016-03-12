from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool


cdef extern from "indri/QueryEnvironment.hpp" namespace "indri::api":
    cdef cppclass QueryEnvironment:
        QueryEnvironment()  #except +

        void setMemory(int)
        void setBaseline(string)
        void setSingleBackgroundModel(bool)
        void setMaxWildcardTerms(int)
        void addServer(string)
        void addIndex(string)
        void close()
        void removeServer(string)
        void removeIndex(string)
        long long termCountUnique()
        long long termCount()
        long long termCount(string)
        long long stemCount(string)
        long long termFieldCount(string, string)
        long long stemFieldCount(string, string)
        long long documentCount()
        long long documentCount(string)
        long long documentStemCount(string)
        double expressionCount(string, string)
        double documentExpressionCount(string, string)
        string stemTerm(string)
        #std::vector<DocumentVector*> documentVectors( const std::vector<lemur::api::DOCID_T>& documentIDs );
        #void setScoringRules( const std::vector<std::string>& rules );
        #void setStopwords( const std::vector<std::string>& stopwords );


        #void addIndex( class IndexEnvironment& environment );

        #QueryResults runQuery(QueryRequest)
        #std::vector<indri::api::ScoredExtentResult> runQuery( const std::string& query, int resultsRequested, const std::string &queryType = "indri" );
        #std::vector<indri::api::ScoredExtentResult> runQuery( const std::string& query, const std::vector<lemur::api::DOCID_T>& documentSet, int resultsRequested, const std::string &queryType = "indri" );
        #QueryAnnotation* runAnnotatedQuery( const std::string& query, int resultsRequested, const std::string &queryType = "indri" );
        #QueryAnnotation* runAnnotatedQuery( const std::string& query, const std::vector<lemur::api::DOCID_T>& documentSet, int resultsRequested, const std::string &queryType = "indri" );

        #std::vector<indri::api::ParsedDocument*> documents( const std::vector<lemur::api::DOCID_T>& documentIDs );
        #std::vector<indri::api::ParsedDocument*> documents( const std::vector<indri::api::ScoredExtentResult>& results );
        #std::vector<std::string> documentMetadata( const std::vector<lemur::api::DOCID_T>& documentIDs, const std::string& attributeName );
        #std::vector<std::string> documentMetadata( const std::vector<indri::api::ScoredExtentResult>& documentIDs, const std::string& attributeName );
        #std::vector<std::string> pathNames( const std::vector<indri::api::ScoredExtentResult>& results );
        #std::vector<indri::api::ParsedDocument*> documentsFromMetadata( const std::string& attributeName, const std::vector<std::string>& attributeValues );
        #std::vector<lemur::api::DOCID_T> documentIDsFromMetadata( const std::string& attributeName, const std::vector<std::string>& attributeValue );
        #std::vector<ScoredExtentResult> expressionList(string, string)
        #std::vector<std::string> fieldList();
        #int documentLength(lemur::api::DOCID_T documentID);
        #std::vector<DocumentVector*> documentVectors( const std::vector<lemur::api::DOCID_T>& documentIDs );
        #const std::vector<indri::server::QueryServer*>& getServers()

        #void setFormulationParameters(Parameters &p);
