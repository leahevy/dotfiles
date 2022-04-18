#!/usr/bin/env python
from setuptools import setup

project_name = "mydotfiles"
project_version = "0.0.1"

with open("requirements.txt", "r") as f:
    required_packages = f.read().strip().split()

setup_info = dict(
    name=project_name,
    version=project_version,
    author="Leah Lackner",
    author_email="leah.lackner+github@gmail.com",
    url="https://github.com/evyli/.dotfiles",
    description="My dotfiles",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    platforms="Linux, Mac OSX",
    license="GPLv3",
    include_package_data=True,
    classifiers=[
        "Development Status :: 2 - Pre-Alpha",
        "Environment :: Console",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: GPLv3",
        "Operating System :: MacOS :: MacOS X",
        "Operating System :: POSIX :: Linux",
        "Programming Language :: Python :: 3",
    ],
    zip_safe=True,
    entry_points={
        "console_scripts": ["mydotfiles=mydotfiles.populate:main"],
    },
    install_requires=required_packages,
)
setup(**setup_info)
