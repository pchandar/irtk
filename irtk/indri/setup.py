from os.path import join
import numpy


def configuration(parent_package='', top_path=None):
    from numpy.distutils.misc_util import Configuration

    config = Configuration('indri', parent_package, top_path)

    config.add_subpackage('tests')

    extra_compile_args = ['-DSTDC_HEADERS=1', '-DHAVE_SYS_TYPES_H=1', '-DHAVE_SYS_STAT_H=1',
                          '-DHAVE_STDLIB_H=1', '-DHAVE_STRING_H=1', '-DHAVE_MEMORY_H=1', '-DHAVE_STRINGS_H=1',
                          '-DHAVE_INTTYPES_H=1', '-DHAVE_STDINT_H=1', '-DHAVE_UNISTD_H=1', '-DHAVE_FSEEKO=1',
                          '-DHAVE_EXT_ATOMICITY_H=1', '-DP_NEEDS_GNU_CXX_NAMESPACE=1', '-DHAVE_MKSTEMP=1',
                          '-DHAVE_MKSTEMPS=1', '-stdlib=libstdc++', '-g', '-O3']

    config.add_library('indri',
                       sources=[join('indri', 'xpdf', 'src', '*.cc'),
                                join('indri', 'antlr', 'src', '*.cpp'),
                                join('indri', 'lemur', 'src', '*.c'),
                                join('indri', 'lemur', 'src', '*.cpp'),
                                join('indri', 'src', '*.cpp')],
                       include_dirs=[join('indri', 'xpdf', 'include'),
                                     join('indri', 'antlr', 'include'),
                                     join('indri', 'lemur', 'include', 'lemur'),
                                     join('indri', 'include'),
                                     join('indri', 'lemur', 'include'),
                                     join('indri', 'xpdf', 'include'),
                                     join('indri', 'antlr', 'include')],
                       extra_compiler_args=extra_compile_args,
                       extra_link_args=['-stdlib=libstdc++','-stdlib=libstdc11++', '-g', '-O3'],
                       )

    config.add_extension('query_env',
                         sources=['query_env.cpp'],
                         include_dirs=[numpy.get_include(),
                                       join('indri', 'include'),
                                       join('indri', 'lemur', 'include'),
                                       join('indri', 'xpdf', 'include'),
                                       join('indri', 'antlr', 'include')],
                         libraries=['indri'],  # , 'xpdf', 'antlr', 'lemur'],
                         extra_compile_args=extra_compile_args,
                         extra_link_args=['-lstdc++', '-stdlib=libstdc++', '-g', '-O3'],
                         )


    return config


if __name__ == '__main__':
    from numpy.distutils.core import setup

    setup(**configuration(top_path='').todict())
