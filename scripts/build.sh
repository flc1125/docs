#!/bin/bash

set -ev

pip install \
        mkdocs==1.0.4 \
        mkdocs-material==4.5.0 \
        pygments \
        pymdown-extensions \
        mkdocs-minify-plugin

exit 0