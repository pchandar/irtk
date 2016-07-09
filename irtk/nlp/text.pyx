# cython: c_string_type=str, c_string_encoding=ascii, embedsignature=True, linetrace=True
# distutils: define_macros=CYTHON_TRACE_NOGIL=1

from __future__ import print_function
from cython.operator cimport dereference as deref, preincrement as inc
from libc.stdio cimport *
from .text cimport Vocabulary
from .text cimport conll_tokenize
import numpy as np

cdef class Vocab:
    cdef Vocabulary*_thisptr
    cdef weights

    def __cinit__(Vocab self):
        self._thisptr = NULL

    def __init__(Vocab self):
        self._thisptr = new Vocabulary()
        self.weights = None

    cdef int _check_alive(Vocab self) except -1:
        if self._thisptr == NULL:
            raise RuntimeError("Wrapped C++ object is deleted")
        else:
            return 0

    def __dealloc__(Vocab self):
        if self._thisptr != NULL:
            del self._thisptr

    def count(Vocab self, str word):
        py_byte_string = word.encode('UTF-8', errors='ignore')
        cdef char*c_string = py_byte_string
        return self._thisptr.getWordCount(c_string)

    def index(Vocab self, str word):
        py_byte_string = word.encode('UTF-8', errors='ignore')
        cdef char*c_string = py_byte_string
        return self._thisptr.getIndex(c_string)

    def size(Vocab self):
        return self._thisptr.size()

    def add(Vocab self, str word):
        py_byte_string = word.encode('UTF-8', errors='ignore')
        cdef char*c_string = py_byte_string
        return self._thisptr.addWord(c_string, 0)

    def save(Vocab self, str filepath):
        py_byte_string = filepath.encode('UTF-8')
        cdef char*c_string = py_byte_string
        self._thisptr.save(c_string)

    def load(Vocab self, str filepath):
        py_byte_string = filepath.encode('UTF-8')
        cdef char*c_string = py_byte_string
        self._thisptr.load(c_string)

    def get_weights(Vocab self):
        if self.size() > self.weights.shape[0]:
            size_diff = self.size() - self.weights.shape[0]
            self.weights = np.concatenate((self.weights, np.random.rand(size_diff, self.weights.shape[1])), axis=0)
        return self.weights

    def load_word2vec(Vocab self, str filepath):
        first = True
        cdef long rowid = 0

        filename_byte_string = filepath.encode("UTF-8")
        cdef char*fname = filename_byte_string

        cdef FILE*cfile
        cfile = fopen(fname, "rb")
        if cfile == NULL:
            raise FileNotFoundError(2, "No such file or directory: '%s'" % filepath)

        cdef char *line = NULL
        cdef size_t l = 0
        cdef ssize_t read

        while True:
            read = getline(&line, &l, cfile)

            if read == -1: break

            if first:
                num_row = int(line.split(' ')[0])
                dim = int(line.split(' ')[1])
                self.weights = np.zeros(shape=(num_row, dim), dtype=float)
                first = False
            else:
                line_utf = (<bytes> line).decode('utf8', errors='strict')
                word = line_utf.split()[0].rstrip()
                self.add(word)
                self.weights[self.index(word)] = list(map(float, line_utf.split()[1:]))
                rowid += 1
        fclose(cfile)

    def __enter__(Vocab self):
        self._check_alive()
        return self

    def __exit__(Vocab self, exc_tp, exc_val, exc_tb):
        if self._thisptr != NULL:
            del self._thisptr
            self._thisptr = NULL  # inform __dealloc__
        return False  # propagate exceptions

def tokenize(str sentence, str tokenizer_type= "conll"):
    cdef vector[Token*] tokens = conll_tokenize(sentence, 0)
    cdef vector[Token*].iterator it = tokens.begin()
    output = []
    while it != tokens.end():
        output.append((deref(it).text, deref(it).offset))
        inc(it)
    return output

def text_to_word_sequence(vocab: Vocab,
                          text: str,
                          stem=False,
                          normalize_url=False,
                          normalize_number=False,
                          lower = True):
    if lower:
        text = text.lower()
    return [vocab.add(_f[0]) for _f in tokenize(text) if _f]

def stem(str token):
    pass
