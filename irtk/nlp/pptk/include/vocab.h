#ifndef PPTK_VOCAB_H
#define PPTK_VOCAB_H

#define MAX_STRING 200
#define MAX_CODE_LENGTH 40
namespace irtk {

class Vocabulary {

  int static vocabCompare(const void *a, const void *b) {
    return ((struct vocab_word *) b)->count - ((struct vocab_word *) a)->count;
  }

  struct vocab_word {
    long long count;
    char *word;
  };


 private :

  const int vocab_hash_size = 30000000;  // Maximum 30 * 0.7 = 21M words in the vocabulary
  long long vocab_max_size = 10000;
  long long vocab_size = 0;
  int min_reduce = 1;
  long long train_words = 0;
  //long long file_size = 0;

  int getHashForWord(const char *word);
  void sort(int);
  void shrinkVocab();


  struct vocab_word *vocab;

  int *vocab_hash;


 public:
  Vocabulary();
  ~Vocabulary();

  long long getWordCount(const char *);

  long long addWord(const char *, long long);
  long long getIndex(const char *);

  void save(char *);
  void load(char *);
  void load_word2vec(char *);

  long long size() { return vocab_size; }

};
}


#endif //PPTK_VOCAB_H
