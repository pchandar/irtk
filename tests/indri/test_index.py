from os import path

import pytest
from irtk.indri.indexer import Indexer, IndriIndexParam
from ..helpers import get_test_file


def test_indexer():
    param = IndriIndexParam()
    param.fields = ['documents']
    indexer = Indexer("tests/data/tinyTestCollection/index", param)
    indexer.add_file("tests/data/tinyTestCollection/data/coll2.txt", "trectext")
    indexer.close()
    assert 1 == 2
