#!/bin/bash -e

echo " Start compile freecontact (will take ~1 min)"

cd /data/commons/MULTICOM_db_tools//tools/DNCON2

cd freecontact-1.0.21

autoreconf -f -i

make clean

./configure --prefix=/data/commons/MULTICOM_db_tools//tools/DNCON2/freecontact-1.0.21 LDFLAGS="-L/data/commons/MULTICOM_db_tools//tools/OpenBLAS/lib -L/data/commons/MULTICOM_db_tools//tools/boost_1_55_0/lib" CFLAGS="-I/data/commons/MULTICOM_db_tools//tools/OpenBLAS/include -I/data/commons/MULTICOM_db_tools//tools/boost_1_55_0/include"  CPPFLAGS="-I/data/commons/MULTICOM_db_tools//tools/OpenBLAS/include -I/data/commons/MULTICOM_db_tools//tools/boost_1_55_0/include" --with-boost=/data/commons/MULTICOM_db_tools//tools/boost_1_55_0/

make

make install

echo "installed" > /data/commons/MULTICOM_db_tools//tools/DNCON2/freecontact-1.0.21/install.done

