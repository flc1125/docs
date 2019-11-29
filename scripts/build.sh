#!/bin/bash

set -ev

# 安装依赖扩展
pip install -r requirements.txt

mkdocs -V

# echo -e "machine github.com\n  login ${GITHUB_TOKEN}" > ~/.netrc

exit 0