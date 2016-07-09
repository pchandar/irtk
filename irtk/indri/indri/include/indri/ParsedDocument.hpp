/*==========================================================================
 * Copyright (c) 2003-2004 University of Massachusetts.  All Rights Reserved.
 *
 * Use of the Lemur Toolkit for Language Modeling and Information Retrieval
 * is subject to the terms of the software license set forth in the LICENSE
 * file included with this software, and also available at
 * http://www.lemurproject.org/license.html
 *
 *==========================================================================
 */


//
// ParsedDocument
//
// 12 May 2004 -- tds
//

#ifndef INDRI_PARSEDDOCUMENT_HPP
#define INDRI_PARSEDDOCUMENT_HPP

#include "indri/greedy_vector"
#include "indri/TagExtent.hpp"
#include "indri/TermExtent.hpp"
#include "indri/MetadataPair.hpp"
#include <string>
#include <vector>
namespace indri
{
  namespace api 
  {
    
    struct ParsedDocument {  
      const char* text;
      size_t textLength;

      const char* content;
      size_t contentLength;

      std::string getContent() {
        return std::string (content, contentLength);
      }
      
      indri::utility::greedy_vector<char*> terms;
      std::vector<char*> terms_py(){
        std::vector<char*> response;

          for( size_t i=0; i<terms.size(); i++ ) {
            response.push_back( terms.at(i) );
          }
        return response;
      }

      indri::utility::greedy_vector<indri::parse::TagExtent *> tags;
      std::vector<indri::parse::TagExtent*> tags_py(){
        std::vector<indri::parse::TagExtent*> response;

          for( size_t i=0; i<tags.size(); i++ ) {
            response.push_back( tags.at(i) );
          }
        return response;
      }

      indri::utility::greedy_vector<indri::parse::TermExtent> positions;
      std::vector<indri::parse::TermExtent> positions_py(){
        std::vector<indri::parse::TermExtent> response;

          for( size_t i=0; i<positions.size(); i++ ) {
            response.push_back( positions.at(i) );
          }
        return response;
      }

      indri::utility::greedy_vector<indri::parse::MetadataPair> metadata;
      std::vector<indri::parse::MetadataPair> metadata_py(){
        std::vector<indri::parse::MetadataPair> response;

          for( size_t i=0; i<metadata.size(); i++ ) {
            response.push_back( metadata.at(i) );
          }
        return response;
      }

    };
  }
}

#endif // INDRI_PARSEDDOCUMENT_HPP

