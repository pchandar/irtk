from django.shortcuts import render
from string import punctuation
from irtk.indri.query_env import PyQueryEnvironment
from watson_developer_cloud import NaturalLanguageClassifierV1
from watson_developer_cloud import AlchemyLanguageV1

from pandas import DataFrame
import pandas as pd
import json


def get_document_mapping():
    data = json.load(open('/Users/pcravich/repo/personal-agents/search/nlctaglist.json'))
    labels = list(map(lambda x: x['labels'], data))
    df = DataFrame.from_dict(labels[0], orient='index').transpose()
    for i in range(1, len(labels)):
        df = df.append(DataFrame.from_dict(labels[i], orient='index').transpose(), ignore_index=True)
    df['url'] = list(map(lambda x: x['url'], data))
    return df


def index(request):
    return render(request, 'search_interface/index.html', {})


def get_annotation(text, alchemy_language_api):
    """
    Given a
    :param text: a string of text
    :param alchemy_language_api: service object
    the functions
    :return: map containing the combined results of running the Alchemy Language Service on the text

    >>> alchemy_language_api = AlchemyLanguageV1(api_key='3307ab763017a099c5f8b126343912371dc24f80')
    >>> annotations = get_annotation("This is a sample text with Boston and Watson", alchemy_language_api)
    >>> set(map(lambda x: x['text'], annotations['keywords']))
    set([u'Boston', u'Watson', u'sample text'])
    """

    try:
        combined_operations = ['entity', 'keyword', 'taxonomy', 'concept']
        annotations = alchemy_language_api.combined(text=text, extract=combined_operations, )
        annotated_text = {'keywords': annotations['keywords'],
                          'concepts': annotations['concepts'],
                          'taxonomy': annotations['taxonomy'],
                          'entities': annotations['entities']
                          }
    except Exception as e:
        annotated_text = {
            'keywords': [],
            'concepts': [],
            'taxonomy': [],
            'entities': []
        }
    return annotated_text

def results(request):
    # Create your views here.
    query_text = request.GET.get('input_query', '').strip(punctuation)
    env = PyQueryEnvironment()
    env.add_index('/Users/pcravich/data/index/hr/hr_keywords_index/')

    if query_text == '':
        context = {'query_text': query_text, 'results': ([], [], [])}
    else:

        #df = get_document_mapping()
        #natural_language_classifier = NaturalLanguageClassifierV1(
        #     username='97a5e0fa-9ced-434f-81f8-5df687e8da58',
        #     password='yzm0AA6PcEve')
        # response = natural_language_classifier.classify("3a84dfx64-nlc-21332", query_text)
        # classes = response['classes']
        # top_classes = [(x['class_name'], x['confidence']) for x in classes if x['confidence'] > 0.4]

        # if len(top_classes) > 0:
        #     print(top_classes[0][0])
        #     subset_urls = df[(df[top_classes[0][0]] > 0.3)].url
        #
        #     print(len(list(set(subset_urls))))
        #     docids = env.get_documentids(list(set(subset_urls)))
        #     res = env.run_indri_query(query_text, 10, docids)
        # else:

            # print(top_classes[0:3])
        alchemy_language_api = AlchemyLanguageV1(api_key='3307ab763017a099c5f8b126343912371dc24f80')

        kword = ' '.join([kw['text'] for kw in get_annotation(query_text, alchemy_language_api)['keywords']])

        if kword.strip() == '':
            res = env.run_indri_query(query_text, 10)
        else:
            print(kword)
            res = env.run_indri_query(kword, 10)

        results = [(x[1], env.document_metadata(x[0], 'title'), x[2]) for x in res.results_iterator()]
        context = {'query_text': query_text, 'results': results}
    return render(request, 'search_interface/results.html', context)