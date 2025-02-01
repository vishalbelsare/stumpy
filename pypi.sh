#!/bin/sh

# 1. Update version number in pyproject.toml
# 2. Update CHANGELOG
# 3. Update README with new features/functions/tutorials
# 4. Determine minimum versions and dependencies with ./min.py
# 5. Bump minimum versions and dependencies
#    a) pyproject.toml
#    b) requirements.txt
#    c) environment.yml
#    d) .github/worflows/github-actions.yml
#    e) recipes/meta.yaml in conda-feedstock
#    f) README.rst
# 6. Commit all above changes as the latest version number and push
#
# For conda-forge
# 1. Fork the stumpy-feedstock: https://github.com/conda-forge/stumpy-feedstock
# 2. Create a new branch for the new version:
#    git checkout -b v1.0.0
# 3. In the recipe/meta.yaml file
#    a) Update version number on line 2
#    b) Update the sha256 on line 10 according to what is found on PyPI
#       in the "Download files" section of the left navigation pane for
#       the tar.gz file: https://pypi.org/project/stumpy/#files
#    c) Reset the build number (to zero) on line 14 since this is a new version
# 4. Commit the changes and push upstream for a PR
# 5. Check the checkboxes in the PR
# 6. Add a comment with "@conda-forge-admin, please rerender"
#
# For readthedocs
# 1. Update the docs/api.rst to include new features/functions
#
# For socializing
# 1. Post on Twitter
# 2. Post on LinkedIn
# 3. Post on Reddit
# 4. Post new tutorials on Medium
#
# To check that the distribution is valid, execute:
# twine check dist/* 
#
# Github Release
# 1. Navigate to the Github release page: https://github.com/TDAmeritrade/stumpy/releases
# 2. Click "Draft a new release": https://github.com/TDAmeritrade/stumpy/releases/new
# 3. In the "Tag version" box, add the version number i.e., "v1.0.0"
# 4. In the Release title" box, add the version number i.e., "v1.0.0"
# 5. In the "Describe this release" box, add the description i.e., "Version 1.1.0 Release"
# 6. Finally, click the "Publish release" button
#
# PyPI Stats - https://packaging.python.org/guides/analyzing-pypi-package-downloads/
# SELECT date, count, SUM(count) OVER (ORDER BY date) AS cumsum
# FROM (
#     SELECT DATE(timestamp) AS date, COUNT(*) as count
#     FROM `bigquery-public-data.pypi.file_downloads`
#     WHERE file.project = 'stumpy'
#         AND DATE(timestamp)
#             BETWEEN DATE('2019-01-01')
#             AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
#     GROUP BY DATE(timestamp)
# )
# ORDER BY date

###############
#  Functions  #
###############

upload_test_pypi()
{
    # Upload to Test PyPi
    if ! [ -f $HOME/.pypirc ]; then
        # .pypirc file does not exist, prompt for API token
        twine upload --verbose --repository-url https://test.pypi.org/legacy/ dist/*
    else
        # Get API token from .pypirc file
        twine upload --verbose -r testpypi dist/*
    fi
}

upload_pypi()
{
    # Upload to PyPi
    if ! [ -f $HOME/.pypirc ]; then
        # .pypirc file does not exist, prompt for API token
        twine upload dist/*
    else
        # Get API token from .pypirc file
        twine upload -r pypi dist/*
    fi
}

# Use API Token instead of username+password
# https://pypi.org/help/#apitoken
# Place the API Token(s) in your $HOME/.pypirc
#
# # Example .pypirc file
#
# [distutils]
# index-servers =
#     pypi
#     testpypi
#
# [pypi]
# repository = https://upload.pypi.org/legacy/
# username = __token__
# password = <PyPI API Token>
#
# [testpypi]
# repository = https://test.pypi.org/legacy/
# username = __token__
# password = <Test PyPI API Token>

###########
#   Main  #
###########

rm -rf dist
python3 -m build --sdist --wheel
upload_test_pypi
# upload_pypi
rm -rf build dist stumpy.egg-info
