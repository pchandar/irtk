import pytest

from irtk.nlp.text import Vocab, text_to_word_sequence

# def test_getCount():
#     v = Vocab()
#     # v.add('test')
#     # v.add('test1')
#     # v.add('test34')
#     # v.add('test')
#     # #print('test')
#     # print('Count: ' + str(v.index('test1')))
#     # print('Size: ' + str(v.size()))
#     v.load('/Users/pcravich/Downloads/test.vocab')
#     v.save('/Users/pcravich/Downloads/test1.vocab')
#     assert v.count('test') == 2
#
# def test_loadvec():
#     v = Vocab()
#     # v.add('test')
#     # v.add('test1')
#     # v.add('test34')
#     # v.add('test')
#     # #print('test')
#     # print('Count: ' + str(v.index('test1')))
#     # print('Size: ' + str(v.size()))
#     v.load_word2vec('/Users/pcravich/repo/irtk/irtk/nlp/tests/word2vec.data')
#     #print(text_to_word_sequence(v, 'the test string'))
#     #v.save('/Users/pcravich/Downloads/test1.vocab')
#     #print('\n')
#     print(v.add('kjsdnks'))
#     #print(v.add('lksamla'))
#     #print(v.size())
#     print(v.get_weights().shape)
#     assert v.count('the') == 1