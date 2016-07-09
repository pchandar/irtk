from os.path import join
import numpy


def configuration(parent_package='', top_path=None):
    from numpy.distutils.misc_util import Configuration

    config = Configuration('nlp', parent_package, top_path)

    extra_compile_args = ['-DSTDC_HEADERS=1', '-DHAVE_SYS_TYPES_H=1', '-DHAVE_SYS_STAT_H=1',
                          '-DHAVE_STDLIB_H=1', '-DHAVE_STRING_H=1', '-DHAVE_MEMORY_H=1', '-DHAVE_STRINGS_H=1',
                          '-DHAVE_INTTYPES_H=1', '-DHAVE_STDINT_H=1', '-DHAVE_UNISTD_H=1', '-DHAVE_FSEEKO=1',
                          '-DHAVE_EXT_ATOMICITY_H=1', '-DP_NEEDS_GNU_CXX_NAMESPACE=1', '-DHAVE_MKSTEMP=1',
                          '-DHAVE_MKSTEMPS=1', '-stdlib=libstdc++', '-g', '-O3']

    config.add_library('pptk',
                       sources=[join('pptk', 'src', '*.cpp')],
                       include_dirs=[join('pptk', 'include')],
                       extra_compiler_args=extra_compile_args,
                       extra_link_args=['-stdlib=libstdc++', '-stdlib=libstdc11++', '-g', '-O3'],
                       )

    config.add_extension('text',
                         sources=['text.cpp'],
                         include_dirs=[numpy.get_include(), join('pptk', 'include')],
                         libraries=['pptk'],
                         extra_compile_args=extra_compile_args,
                         extra_link_args=['-lstdc++', '-stdlib=libstdc++', '-g', '-O3'],
                         )
    return config

if __name__ == '__main__':
    from numpy.distutils.core import setup

    setup(**configuration(top_path='').todict())
