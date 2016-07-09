from io import StringIO

import pandas as pd


class TRECResult:
    __trec_columns = ['qid', 'q0', 'docid', 'rank', 'score', 'runid', 'internal_id']
    __trec_types = ['string']
    __runid = str('indri_default')
    __ranked_list = pd.DataFrame(columns=__trec_columns)

    def __init__(self, runid):
        self.__runid = runid
        self.__ranked_list = pd.DataFrame(columns=self.__trec_columns)

    def get_results(self):
        return self.__ranked_list

    def to_string(self):
        s = StringIO()
        self.__ranked_list.sort_values(by=['qid', 'rank', 'score', 'docid'], ascending=[1, 1, 0, 1])
        self.__ranked_list.to_csv(path_or_buf=s, sep=' ', header=False)
        return s.read()

    def add_result(self, qid: str, docid: str, rank: int, score: float, internal_id: int) -> None:
        self.__ranked_list.loc[len(self.__ranked_list)] = [qid, 'Q0', docid, score, rank, self.__runid, internal_id]

    def add_result_set(self, query_df: pd.DataFrame) -> None:
        self.__ranked_list.concat(query_df)

    @staticmethod
    def load_result_file(file_name):
        pass
