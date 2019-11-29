#!/bin/bash

set -ev

# mkdocs gh-deploy --force --clean
mkdocs build --clean
upx login "${UPX_SERVICE_NAME}" "${UPX_OPERATOR}" "${UPX_PASSWORD}"
upx sync ./site/

exit 0