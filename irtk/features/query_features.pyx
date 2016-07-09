# from ..indri cimport query_env
#
#
#
#
# def get_query_features(str query, query_env.PyQueryEnvironment env):
#     """
#     Extracts query features for learning to rank using the provided index
#     :param query: string
#     :param env: PyQueryEnvironment that provides access to the index
#
#     :return: a
#     """
#     # indri::api::QueryParserWrapper *parser = indri::api::QueryParserFactory::get(query, "indri");
#     # indri::lang::ScoredExtentNode* rootNode = parser->query();
#     # indri::lang::RawScorerNodeExtractor extractor;
#     # rootNode->walk(extractor);
#     # std::vector<indri::lang::RawScorerNode*>& scorerNodes = extractor.getScorerNodes();
#     #
#     # for (int i = 0; i < scorerNodes.size(); i++){
#     #     std::string qterm = environment.stemTerm(scorerNodes[i]->queryText());
#     #     queryString.push_back(qterm);
#     #     if(environment.stemCount(qterm) == 0)
#     #         continue;
#     #     if( _queryTokens.find(qterm) == _queryTokens.end() )
#     #         _queryTokens.insert(make_pair( qterm, 1));
#     #     else
#     #         _queryTokens[qterm] += 1;
#     # }
#     #
#     # // Initialize vectors
#     #
#     #
#     # _query_collectionFrequency.set_size(_queryTokens.size());
#     # _query_documentFrequency.set_size(_queryTokens.size());
#     #
#     #
#     #
#     # // Now obtain the statistics
#     # int i = 0;
#     # map<std::string, int>::const_iterator iter;
#     # for (iter=_queryTokens.begin(); iter != _queryTokens.end(); ++iter) {
#     #     std::string stem = environment.stemTerm(iter->first);
#     #     _query_collectionFrequency(i) = (double) environment.stemCount(stem);
#     #     _query_documentFrequency(i) = (double) environment.documentStemCount(stem);
#     #     ++i;
#     #
#     # }
#     pass