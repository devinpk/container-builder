#!/bin/sh
git clone https://github.com/percona/percona-xtrabackup.git
# for CN
#git clone https://gitee.com/mirrors/percona-xtrabackup.git
cd percona-xtrabackup
git checkout 8.0
git submodule update --init --recursive
cd -
docker buildx build -t devinpk/percona-xtrabackup:8.0 .
