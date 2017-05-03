from os import path

import pytest
from irtk.indri.query_env import PyQueryEnvironment
from .helpers import get_test_file

class TestPyQueryEnvironment:
    env = PyQueryEnvironment()
    true_docids = []  # [doc names]
    true_terms = dict()  # term: (tf, df)

    @classmethod
    def setup_class(cls):
        print(get_test_file('tinyTestCollection/index'))
        cls.env.add_index(get_test_file('tinyTestCollection/index'))

        with open(get_test_file('tinyTestCollection/docIDs.txt')) as f:
            cls.true_docids = [docid.strip() for docid in f]

        with open(get_test_file('tinyTestCollection/cfanddf.txt')) as f:
            cls.true_terms = {terms.strip().split()[0]: (int(terms.strip().split()[1]),
                                                         int(terms.strip().split()[2]))
                              for terms in f}

    @classmethod
    def teardown_class(cls):
        cls.env.close()

    def test_add_index_exception(self):
        with pytest.raises(RuntimeError):
            self.env.add_index(path.dirname(__file__) + 'unknown path')

    def test_document_name(self):
        docids = [self.env.document_name(docid) for docid in range(1, 21)]
        assert docids == self.true_docids

    def test_document_count(self):
        assert self.env.document_count() == 20

    def test_document_expression_count_punctuations(self):
        with pytest.raises(RuntimeError):
            self.env.document_expression_count('x**')

    def test_document_counts(self):
        """
        NOTE: The terms in the test index were not stemmed, so document_count(), document_expression_count()
                and document_stem_count() should all yield the same results
        """
        # The true dfs
        truth = [self.true_terms[term][1] for term in self.true_terms.keys()]

        # The document count
        actual_df = [self.env.document_count(term) for term in self.true_terms.keys()]

        # The document expression count
        actual_dexp = [self.env.document_expression_count('#ow1(' + term + ')') for term in self.true_terms.keys()]

        # The document stem count
        actual_stem = [self.env.document_stem_count(term) for term in self.true_terms.keys()]

        assert truth == actual_dexp == actual_df == actual_stem

    def test_term_counts(self):
        """
        NOTE: The terms in the test index were not stemmed, so term_count(), expression_count()
                and stem_count() should all yield the same results
        """
        # The true dfs
        truth = [self.true_terms[term][0] for term in self.true_terms.keys()]

        # The term count
        actual_df = [self.env.term_count(term) for term in self.true_terms.keys()]

        # The document expression count
        actual_dexp = [self.env.expression_count('#ow1(' + term + ')') for term in self.true_terms.keys()]

        # The document stem count
        actual_stem = [self.env.stem_count(term) for term in self.true_terms.keys()]

        assert truth == actual_dexp == actual_df == actual_stem

    def test_term_count_unique(self):
        assert self.env.term_count_unique() == 3174

    def test_document_length(self):
        lengths = [self.env.document_length(docid) for docid in range(1, 6)]
        assert lengths == [748, 649, 528, 621, 767]

        # def test_run_query(self):
        #     self.fail()

        # def test_document_vectors(self):
        #     self.fail()
        #
        # def test_documents(self):
        #     self.fail()
        #
