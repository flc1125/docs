#!/bin/bash

set -ev

# 安装 UPX 命令工具
sudo apt-get install -y golang
sudo go get github.com/upyun/upx
go version

exit 0