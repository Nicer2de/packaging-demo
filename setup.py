from setuptools import setup

setup()

"""
Shortcomings of sdist format

1. May make assumptions about customer mcahine:
   e.g. requires "gcc" to run :gcc numpy/*.c"

2. Is slow: setup.py must be executed, compilation may
   be required.

3. Is insecure: setup.py may contain arbitrary code
"""
