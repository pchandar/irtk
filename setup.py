import distutils.command.build
import distutils.command.clean
import distutils.unixccompiler
import os
import platform
import subprocess
import sys

import setuptools.command.build_ext
import setuptools.command.build_py
import setuptools.command.develop
import setuptools.command.install
from setuptools import setup, Extension, \
    distutils, Command, find_packages
from Cython.Build import cythonize

with open('README.md') as readme_file:
    readme = readme_file.read()

with open('requirements.txt') as req_file:
    requirements = [req.strip() for req in req_file]

version = '0.0.1'


################################################################################
# Custom build commands
################################################################################


class build_deps(Command):
    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        build_all_cmd = ['bash', 'irtk/lib/build_all.sh']
        if subprocess.call(build_all_cmd) != 0:
            sys.exit(1)


class build(distutils.command.build.build):
    sub_commands = [
                       ('build_deps', lambda self: True),
                   ] + distutils.command.build.build.sub_commands


class install(setuptools.command.install.install):
    def run(self):
        if not self.skip_build:
            self.run_command('build_deps')
        setuptools.command.install.install.run(self)


class clean(distutils.command.clean.clean):
    def run(self):
        import os
        import glob
        import shutil

        def delete(pattern):
            for filename in glob.iglob(pattern, recursive=True):
                try:
                    os.unlink(filename)
                except:
                    shutil.rmtree(filename)

        [delete('**/*' + d) for d in ['.pyc', '.pyo', '~', #'.so', '.a', '.dylib',
                                      '__pycache__' ]]
        [delete(d) for d in ['build', 'dist', '.eggs', 'irtk/indri/**/*.cpp',
                             'irtk/indri/**/*.c', '*.egg-info', '.tox', '.coverage']]

        # It's an old-style class in Python 2.7...
        distutils.command.clean.clean.run(self)


################################################################################
# Configure compile flags
################################################################################

include_dirs = []
extra_link_args = []
extra_compile_args = ['-w', '-fPIC', '-m64', '-stdlib=libstdc++', '-Wno-write-strings']
extra_compile_args += ['-DSTDC_HEADERS=1', '-DHAVE_SYS_TYPES_H=1', '-DHAVE_SYS_STAT_H=1', '-DHAVE_LIBIBERTY=1',
                       '-DHAVE_STDLIB_H=1', '-DHAVE_STRING_H=1', '-DHAVE_MEMORY_H=1', '-DHAVE_STRINGS_H=1',
                       '-DHAVE_INTTYPES_H=1', '-DHAVE_STDINT_H=1', '-DHAVE_UNISTD_H=1', '-DHAVE_FSEEKO=1',
                       '-DHAVE_EXT_ATOMICITY_H=1', '-DP_NEEDS_GNU_CXX_NAMESPACE=1', '-DHAVE_MKSTEMP=1',
                       '-DHAVE_MKSTEMPS=1', '-g', '-O3']

if platform.system() == 'Linux':
    extra_compile_args += ['-static-libstdc++']
    extra_link_args += ['-static-libstdc++']

cwd = os.path.dirname(os.path.abspath(__file__))
lib_path = os.path.join(cwd, "irtk", "lib")

include_dirs += [
    lib_path + "/indri/include",
    lib_path + "/indri/include/indri_extras",
    lib_path + "/indri/indri_5_11/lemur/include/lemur",
    lib_path + "/indri/indri_5_11/lemur/include",
    lib_path + "/indri/indri_5_11/xpdf/include",
    lib_path + "/indri/indri_5_11/zlib/include",
    lib_path + "/indri/indri_5_11/antlr/include"
]

extra_link_args.append('-L' + lib_path)

# we specify exact lib names to avoid conflict with lua-torch installs
INDRI_LIB = os.path.join(lib_path, 'libindri.so')
if platform.system() == 'Darwin':
    INDRI_LIB = os.path.join(lib_path, 'libindri.dylib')
extra_link_args.append(INDRI_LIB)

def make_relative_rpath(path):
    if platform.system() == 'Darwin':
        return '-Wl,-rpath,@loader_path/' + path
    else:
        return '-Wl,-rpath,$ORIGIN/' + path

################################################################################
# Declare extensions and package
################################################################################

extensions = []

IndriIndex = Extension("irtk.indri.query",
                       language="c++",
                       extra_compile_args=extra_compile_args,
                       extra_link_args=extra_link_args + [make_relative_rpath('../lib')],
                       include_dirs=include_dirs,
                       sources=['irtk/indri/query.pyx'],
                       define_macros=[('CYTHON_TRACE', '1')])
extensions.append(IndriIndex)


IndriIndex = Extension("irtk.indri.indexer",
                       language="c++",
                       extra_compile_args=extra_compile_args,
                       extra_link_args=extra_link_args + [make_relative_rpath('../lib')],
                       include_dirs=include_dirs,
                       sources=['irtk/indri/indexer.pyx'],
                       define_macros=[('CYTHON_TRACE', '1')])
extensions.append(IndriIndex)


# IndriQueryEnv = Extension("irtk.indri.index",
#                           language="c++",
#                           extra_compile_args=extra_compile_args,
#                           extra_link_args=extra_link_args,
#                           include_dirs=include_dirs,
#                           sources=['irtk/indri/index.pyx'],
#                           define_macros=[('CYTHON_TRACE', '1')])
# extensions.append(IndriQueryEnv)

setup(name='irtk',
      version='0.0.1',
      description='Information Retrieval Toolkit',
      long_description=readme + '\n\n',
      author='Praveen Chandar',
      author_email='pcr@udel.edu',
      url='https://github.com/pchandar/irtk',
      install_requires=requirements,
      tests_require=['pytest'],
      test_suite='tests',
      include_package_data=True,
      cmdclass={
          'clean': clean,
          'build_deps': build_deps,
          'build': build,
          'install': install
      },
      packages=find_packages(),
      package_dir={'irtk': 'irtk'},
      package_data={'irtk': ['irtk/lib/*.so*', 'itrk/lib/*.dylib*'] + include_dirs},
      ext_modules=cythonize(extensions)
      )
