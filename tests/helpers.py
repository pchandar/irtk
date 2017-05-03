import pkg_resources
from pyhocon import ConfigFactory


def get_test_file(filename: str):
    return pkg_resources.resource_filename('tests', 'data/' + filename)


def get_test_config():
    return ConfigFactory.parse_file(pkg_resources.resource_filename('tests', 'test_data/test.conf'))
