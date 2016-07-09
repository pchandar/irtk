#ifndef IRTK_TOKENIZER_HPP
#define IRTK_TOKENIZER_HPP

#include <stdio.h>
#include <string>
#include <map>

namespace irtk {
namespace nlp {

class Tokenizer {

 public:
  struct Token {
    std::string text;
    int begin;
    int end;
  };

 public:
  Tokenizer() { }
  //: //_handler(0) {

  //_tokenize_markup = tokenize_markup;
  //_tokenize_entire_words = tokenize_entire_words;


  ~Tokenizer() { }
  std::string tokenize(std::string documnt);
  //TokenizedDocument* tokenize( UnparsedDocument* document );

  //void handle( UnparsedDocument* document );
  //void setHandler( ObjectHandler<TokenizedDocument>& h );

//    protected:
//      void processASCIIToken();
//      void processUTF8Token();
//      void processTag();
//
//      indri::utility::Buffer _termBuffer;
//      UTF8Transcoder _transcoder;
//
//      bool _tokenize_markup;
//      bool _tokenize_entire_words;
//
//    private:
//      ObjectHandler<TokenizedDocument>* _handler;
//      TokenizedDocument _document;
//
//      void writeToken( char* token, int token_len, int extent_begin,
//                       int extent_end );
};
}
}

#endif // IRTK_TOKENIZER_HPP

