# ! /usr/bin/env pythonimport os
import glob
import io
import os
import sys
import warnings

if sys.version_info[:2] < (3, 4):
    raise Exception('This version of gensim needs Python 3.4 or later.')

from Cython.Compiler.Options import directive_defaults
from setuptools import setup, find_packages, Extension
from setuptools.command.build_ext import build_ext

directive_defaults['linetrace'] = True
directive_defaults['binding'] = True


class CustomBuildExt(build_ext):
    """Allow C extension building to fail.

    The C extension speeds up word2vec and doc2vec training, but is not essential.
    """

    warning_message = """
********************************************************************
WARNING: %s could not
be compiled. No C extensions are essential for gensim to run,
although they do result in significant speed improvements for some modules.
%s

Here are some hints for popular operating systems:

If you are seeing this message on Linux you probably need to
install GCC and/or the Python development package for your
version of Python.

Debian and Ubuntu users should issue the following command:

    $ sudo apt-get install build-essential python-dev

RedHat, CentOS, and Fedora users should issue the following command:

    $ sudo yum install gcc python-devel

If you are seeing this message on OSX please read the documentation
here:

http://api.mongodb.org/python/current/installation.html#osx
********************************************************************
"""

    def run(self):
        try:
            build_ext.run(self)
        except Exception:
            e = sys.exc_info()[1]
            sys.stdout.write('%s\n' % str(e))
            warnings.warn(
                self.warning_message +
                "Extension modules" +
                "There was an issue with your platform configuration - see above.")
            exit(0)

    def build_extension(self, ext):
        name = ext.name
        try:
            build_ext.build_extension(self, ext)
        except Exception:
            e = sys.exc_info()[1]
            sys.stdout.write('%s\n' % str(e))
            warnings.warn(
                self.warning_message +
                "The %s extension module" % (name,) +
                "The output above this warning shows how the compilation failed.")
            exit(0)

    # the following is needed to be able to add numpy's include dirs... without
    # importing numpy directly in this script, before it's actually installed!
    # http://stackoverflow.com/questions/19919905/how-to-bootstrap-numpy-installation-in-setup-py
    def finalize_options(self):
        build_ext.finalize_options(self)
        # Prevent numpy from thinking it is still in its setup process:
        # https://docs.python.org/2/library/__builtin__.html#module-__builtin__
        if isinstance(__builtins__, dict):
            __builtins__["__NUMPY_SETUP__"] = False
        else:
            __builtins__.__NUMPY_SETUP__ = False

        import numpy
        self.include_dirs.append(numpy.get_include())


def readfile(fname):
    path = os.path.join(os.path.dirname(__file__), fname)
    return io.open(path, encoding='utf8').read()


model_dir = os.path.join(os.path.dirname(__file__), 'gensim', 'models')
gensim_dir = os.path.join(os.path.dirname(__file__), 'gensim')

cmdclass = {'build_ext': CustomBuildExt}
extra_compile_args = ['-DSTDC_HEADERS=1', '-DHAVE_SYS_TYPES_H=1', '-DHAVE_SYS_STAT_H=1', '-DHAVE_LIBIBERTY=1',
                      '-DHAVE_STDLIB_H=1', '-DHAVE_STRING_H=1', '-DHAVE_MEMORY_H=1', '-DHAVE_STRINGS_H=1',
                      '-DHAVE_INTTYPES_H=1', '-DHAVE_STDINT_H=1', '-DHAVE_UNISTD_H=1', '-DHAVE_FSEEKO=1',
                      '-DHAVE_EXT_ATOMICITY_H=1', '-DP_NEEDS_GNU_CXX_NAMESPACE=1', '-DHAVE_MKSTEMP=1',
                      '-DHAVE_MKSTEMPS=1', '-g', '-O3']
setup(
    name='irtk',
    version='0.0.1',
    description='Python framework for information retireval and nlp experimentation',
    long_description=readfile('README.md'),

    ext_modules=[
        Extension("irtk.nlp.text",
                  language="c++",
                  sources=['irtk/nlp/pptk/src/vocab.cpp', 'irtk/nlp/text.pyx'],
                  include_dirs=[os.path.join('irtk', 'nlp', 'pptk', 'include')],
                  extra_compile_args=extra_compile_args,
                  extra_link_args=['-g', '-O3'],
                  define_macros=[('CYTHON_TRACE', '1')]),
        Extension('irtk.indri.query_env',
                  sources=
                  glob.glob(os.path.join('irtk', 'indri', 'indri', 'xpdf', 'src', '*.cc')) +
                  glob.glob(os.path.join('irtk', 'indri', 'indri', 'antlr', 'src', '*.cpp')) +
                  glob.glob(os.path.join('irtk', 'indri', 'indri', 'lemur', 'src', '*.c')) +
                  glob.glob(os.path.join('irtk', 'indri', 'indri', 'lemur', 'src', '*.cpp')) +
                  glob.glob(os.path.join('irtk', 'indri', 'indri', 'src', '*.cpp')) +
                  ['irtk/indri/query_env.pyx'],
                  extra_compile_args=extra_compile_args,
                  extra_link_args=['-g', '-O3'],
                  language="c++",
                  include_dirs=[
                      os.path.join('irtk', 'indri', 'indri', 'include'),
                      os.path.join('irtk', 'indri', 'indri', 'lemur', 'include'),
                      os.path.join('irtk', 'indri', 'indri', 'lemur', 'include', 'lemur'),
                      os.path.join('irtk', 'indri', 'indri', 'xpdf', 'include'),
                      os.path.join('irtk', 'indri', 'indri', 'antlr', 'include')],
                  define_macros=[('CYTHON_TRACE', '1')])
    ],
    cmdclass=cmdclass,
    packages=find_packages(),

    author='Praveen Chandar',
    author_email='pcr@udel.edu',

    url='http://pchandar.github.io',

    keywords='Singular Value Decomposition, SVD, Latent Semantic Indexing, '
             'LSA, LSI, Latent Dirichlet Allocation, LDA, '
             'Hierarchical Dirichlet Process, HDP, Random Projections, '
             'TFIDF, word2vec',

    platforms='any',

    zip_safe=False,

    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Environment :: Console',
        'Intended Audience :: Science/Research',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 3.5',
        'Topic :: Scientific/Engineering :: Artificial Intelligence',
        'Topic :: Scientific/Engineering :: Information Analysis',
        'Topic :: Text Processing :: Linguistic',
    ],

    test_suite="irtk.test",
    setup_requires=[
        'numpy >= 1.3'
    ],
    install_requires=[
        'numpy >= 1.3',
        'scipy >= 0.7.0',
        'six >= 1.5.0',
    ],

    extras_require={
        'distributed': ['Pyro4 >= 4.27'],
        'wmd': ['pyemd >= 0.2.0'],
    },

    include_package_data=True,
)
