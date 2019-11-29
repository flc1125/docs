#!/bin/bash

set -ev

# 安装 UPX 命令工具
apt-get install -y golang
go get github.com/polym/upx
go version

exit 0