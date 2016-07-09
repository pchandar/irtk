# ! /usr/bin/env python
#
# License: 3-clause BSD
import os
import shutil
import subprocess
import sys
from distutils.command.clean import clean as Clean

DISTNAME = 'IRTK'
DESCRIPTION = 'A set of python modules for building a search assistant'
with open('README.md') as f:
    LONG_DESCRIPTION = f.read()
MAINTAINER = 'Praveen Chandar'
MAINTAINER_EMAIL = 'pcr@udel.edu'
URL = 'http://pchandar.github.io'
LICENSE = 'MIT'
VERSION = '0.0.1'

# Optional setuptools features
# We need to import setuptools early, if we want setuptools features,
# as it monkey-patches the 'setup' function
# For some commands, use setuptools
SETUPTOOLS_COMMANDS = {'develop',
                       'release',
                       'bdist_egg',
                       'bdist_rpm',
                       'bdist_wininst',
                       'install_egg_info',
                       'build_sphinx',
                       'egg_info',
                       'easy_install',
                       'upload',
                       'bdist_wheel',
                       'test'
                       '--single-version-externally-managed'}
if SETUPTOOLS_COMMANDS.intersection(sys.argv):
    extra_setuptools_args = dict(
        zip_safe=False,  # the package can run out of an .egg file
        include_package_data=True,
    )
else:
    extra_setuptools_args = dict()


# Custom clean command to remove build artifacts
class CleanCommand(Clean):
    description = "Remove build artifacts from the source tree"

    def run(self):
        Clean.run(self)
        # Remove c files if we are not within a sdist package
        cwd = os.path.abspath(os.path.dirname(__file__))
        remove_c_files = not os.path.exists(os.path.join(cwd, 'PKG-INFO'))
        if remove_c_files:
            cython_hash_file = os.path.join(cwd, 'cythonize.dat')
            if os.path.exists(cython_hash_file):
                os.unlink(cython_hash_file)
            print('Will remove generated .c and .cpp files')
        if os.path.exists('build'):
            shutil.rmtree('build')
        for dirpath, dirnames, filenames in os.walk('irtk'):
            for filename in filenames:
                if any(filename.endswith(suffix) for suffix in
                       (".so", ".pyd", ".dll", ".pyc")):
                    os.unlink(os.path.join(dirpath, filename))
                    continue
                extension = os.path.splitext(filename)[1]
                if remove_c_files and extension in ['.c', '.cpp']:
                    pyx_file = str.replace(filename, extension, '.pyx')
                    if os.path.exists(os.path.join(dirpath, pyx_file)):
                        os.unlink(os.path.join(dirpath, filename))
            for dirname in dirnames:
                if dirname == '__pycache__':
                    shutil.rmtree(os.path.join(dirpath, dirname))


def configuration(parent_package='', top_path=None):
    if os.path.exists('MANIFEST'):
        os.remove('MANIFEST')

    from numpy.distutils.misc_util import Configuration
    config = Configuration(None, parent_package, top_path)

    # Avoid non-useful msg:
    # "Ignoring attempt to set 'name' (from ... "
    config.set_options(ignore_setup_xxx_py=True,
                       assume_default_configuration=True,
                       delegate_options_to_subpackages=True,
                       quiet=True)

    config.add_subpackage('irtk')

    return config


def generate_cython():
    cwd = os.path.abspath(os.path.dirname(__file__))
    print("Cythonizing sources")
    p = subprocess.call([sys.executable, os.path.join(cwd,
                                                      'build_tools',
                                                      'cythonize.py'),
                         'irtk'],
                        cwd=cwd)
    if p != 0:
        raise RuntimeError("Running cythonize failed!")


def setup_package():
    metadata = dict(name=DISTNAME,
                    maintainer=MAINTAINER,
                    maintainer_email=MAINTAINER_EMAIL,
                    description=DESCRIPTION,
                    license=LICENSE,
                    url=URL,
                    version=VERSION,
                    download_url='',
                    requires=[
                        'pytest'
                    ],
                    long_description=LONG_DESCRIPTION,
                    classifiers=['Intended Audience :: Science/Research',
                                 'Intended Audience :: Developers',
                                 'License :: OSI Approved',
                                 'Programming Language :: C',
                                 'Programming Language :: Python',
                                 'Topic :: Software Development',
                                 'Topic :: Scientific/Engineering',
                                 'Operating System :: POSIX',
                                 'Operating System :: Unix',
                                 'Operating System :: MacOS',
                                 'Programming Language :: Python :: 3.5',
                                 ],
                    cmdclass={'clean': CleanCommand},
                    **extra_setuptools_args)

    if len(sys.argv) == 1 or (len(sys.argv) >= 2 and ('--help' in sys.argv[1:] or sys.argv[1] in ('--help-commands',
                                                                                                  'egg_info',
                                                                                                  '--version',
                                                                                                  'clean'))):
        # For these actions, NumPy is not required, nor Cythonization
        #
        # They are required to succeed without Numpy for example when
        # pip is used to install AITK when Numpy is not yet present in
        # the system.
        try:
            from setuptools import setup
        except ImportError:
            from distutils.core import setup

        metadata['version'] = VERSION
    else:
        pass

        from numpy.distutils.core import setup

        metadata['configuration'] = configuration

        if len(sys.argv) >= 2 and sys.argv[1] not in 'config':
            # Cythonize if needed

            print('Generating cython files')
            cwd = os.path.abspath(os.path.dirname(__file__))
            if not os.path.exists(os.path.join(cwd, 'PKG-INFO')):
                # Generate Cython sources, unless building from source release
                generate_cython()

            # Clean left-over .so file
            for dirpath, dirnames, filenames in os.walk(
                    os.path.join(cwd, 'aitk')):
                for filename in filenames:
                    extension = os.path.splitext(filename)[1]
                    if extension in (".so", ".pyd", ".dll"):
                        pyx_file = str.replace(filename, extension, '.pyx')
                        print(pyx_file)
                        if not os.path.exists(os.path.join(dirpath, pyx_file)):
                            os.unlink(os.path.join(dirpath, filename))

    setup(**metadata)


if __name__ == "__main__":
    setup_package()
