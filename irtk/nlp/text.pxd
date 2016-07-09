from libcpp.string cimport string
from libcpp.vector cimport vector
from libc.stdio cimport *

cdef extern from "stdio.h":
    FILE *fopen(const char *, const char *)
    int fclose(FILE *)
    ssize_t getline(char **, size_t *, FILE *)


cdef extern from "CoNLLTokenizer.h" namespace "irtk":
    cdef cppclass Token:
        Token(string, long)
        string text
        long offset
    vector[Token*] conll_tokenize(string, long) except +RuntimeError

cdef extern from "vocab.h" namespace "irtk":
    cdef cppclass Vocabulary:
        long long addWord(const char*, long long)
        long long getIndex(const char*)
        long long size()
        long long getWordCount(const char*)
        void load(char*)
        void load_word2vec(char*)
        void save(char*)


