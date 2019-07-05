#!/bin/bash -e

echo " Start install python2.6 library (will take ~5 min)"

cd /data/commons/MULTICOM_db_tools_v1.1//tools

#wget http://www.python.org/ftp/python/2.6.8/Python-2.6.8.tgz

#tar xzf Python-2.6.8.tgz

cd Python-2.6.8

make clean

./configure --prefix=/data/commons/MULTICOM_db_tools_v1.1//tools/Python-2.6.8 --with-threads --enable-shared --with-zlib=/usr/include

make

make install

