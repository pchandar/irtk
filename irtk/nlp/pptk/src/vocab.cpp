#include "vocab.h"
#include <string>
#include <iostream>
#include <sstream>
#include <fstream>


// Returns hash value of a word (from word2vec)
int irtk::Vocabulary::getHashForWord(const char *word) {
  unsigned long long a, hash = 0;
  for (a = 0; a < strlen(word); a++)
    hash = hash * 257 + word[a];
  hash = hash % vocab_hash_size;
  return hash;
}


int str_compare(const char *s1, const char *s2) {
  while (*s1 != '\0' && *s1 == *s2) {
    s1++;
    s2++;
  }
  return (*s1 - *s2);
}

// Reduces the vocabulary by removing infrequent tokens
void irtk::Vocabulary::shrinkVocab() {
  int a, b = 0;
  unsigned int hash;
  for (a = 0; a < vocab_size; a++)
    if (vocab[a].count > min_reduce) {
      vocab[b].count = vocab[a].count;
      vocab[b].word = vocab[a].word;
      b++;
    } else free(vocab[a].word);
  vocab_size = b;
  for (a = 0; a < vocab_hash_size; a++) vocab_hash[a] = -1;
  for (a = 0; a < vocab_size; a++) {
    // Hash will be re-computed, as it is not actual
    hash = getHashForWord(vocab[a].word);
    while (vocab_hash[hash] != -1)
      hash = (hash + 1) % vocab_hash_size;
    vocab_hash[hash] = a;
  }
  fflush(stdout);
  min_reduce++;
}


long long irtk::Vocabulary::getIndex(const char *word) {
  unsigned int hash = getHashForWord(word);
  while (1) {
    if (vocab_hash[hash] == -1) return -1;
    if (!str_compare(word, vocab[vocab_hash[hash]].word)) return vocab_hash[hash];
    hash = (hash + 1) % vocab_hash_size;
  }
}

// Returns position of a word in the vocabulary; if the word is not found, returns -1
long long irtk::Vocabulary::getWordCount(const char *word) {
  long long idx = getIndex(word);
  if (idx == -1)
    return NULL;
  else
    return vocab[idx].count;
}

// Adds a word to the vocabulary
long long irtk::Vocabulary::addWord(const char *word, long long set_count = 0) {

  long long idx = getIndex(word);
  // Update the Counts
  if (idx == -1) {
    unsigned int hash, length = strlen(word) + 1;
    if (length > MAX_STRING)
      length = MAX_STRING;

    vocab[vocab_size].word = (char *) calloc(length, sizeof(char));
    strncpy(vocab[vocab_size].word, word, length);
    vocab[vocab_size].count = 0;
    vocab_size++;

    // Reallocate memory if needed
    if (vocab_size + 2 >= vocab_max_size) {
      vocab_max_size += 10000;
      vocab = (struct vocab_word *) realloc(vocab, vocab_max_size * sizeof(struct vocab_word));
    }
    hash = getHashForWord(word);
    while (vocab_hash[hash] != -1) hash = (hash + 1) % vocab_hash_size;

    vocab_hash[hash] = vocab_size - 1;

    // set the word count
    if (set_count == 0)
      vocab[vocab_size - 1].count = 1;
    else
      vocab[vocab_size - 1].count = set_count;
    if (vocab_size > vocab_hash_size * 0.7) shrinkVocab();
    return vocab_size - 1;
  }
  else{
    vocab[idx].count++;
    return idx;
  }
}
irtk::Vocabulary::Vocabulary() {
  vocab_hash = (int *) calloc(vocab_hash_size, sizeof(int));
  vocab = (struct vocab_word *) calloc(vocab_max_size, sizeof(struct vocab_word));
  long long a;
  for (a = 0; a < vocab_hash_size; a++) vocab_hash[a] = -1;
  vocab_size = 0;
}

irtk::Vocabulary::~Vocabulary() {
  long long a;
  for (a = 0; a < vocab_size; a++) {
    if (vocab[a].word != NULL) {
      free(vocab[a].word);
    }
  }
  free(vocab[vocab_size].word);
  free(vocab);
}

// Sorts the vocabulary by frequency using word counts
void irtk::Vocabulary::sort(int min_count = 5) {
  int a, size;
  unsigned int hash;
  qsort(&vocab[0], vocab_size - 1, sizeof(struct vocab_word), vocabCompare);
  for (a = 0; a < vocab_hash_size; a++) vocab_hash[a] = -1;
  size = vocab_size;
  train_words = 0;
  for (a = 0; a < size; a++) {
    // Words occuring less than min_count times will be discarded from the vocab
    if (vocab[a].count < min_count) {
      vocab_size--;
      free(vocab[a].word);
      vocab[a].word = NULL;
    } else {
      // Hash will be re-computed, as after the sorting it is not actual
      hash = getHashForWord(vocab[a].word);
      while (vocab_hash[hash] != -1) hash = (hash + 1) % vocab_hash_size;
      vocab_hash[hash] = a;
      train_words += vocab[a].count;
    }
  }
  vocab = (struct vocab_word *) realloc(vocab, (vocab_size + 1) * sizeof(struct vocab_word));
}

void irtk::Vocabulary::save(char *save_vocab_file) {
  std::ofstream myfile;
  myfile.open(save_vocab_file);
  for (long long i = 0; i < vocab_size; i++)
    myfile << vocab[i].word << " " << vocab[i].count << "\n";
  myfile.close();

}


void irtk::Vocabulary::load(char *read_vocab_file) {
  std::string line;

  std::ifstream infile(read_vocab_file);
  while (std::getline(infile, line)) {
    std::istringstream iss(line);
    std::string curWord;
    long long count;
    if (iss >> curWord >> count)
      addWord(curWord.c_str(), count);
    else
      continue;
  }
  infile.close();
}


void irtk::Vocabulary::load_word2vec(char *read_vocab_file) {
  std::string line;

  std::ifstream infile(read_vocab_file);
  while (std::getline(infile, line)) {
    std::istringstream iss(line);
    char *curWord;
    long long count;
    if (iss >> curWord >> count)
      addWord(curWord, count);
    else
      continue;
  }
  infile.close();
}
