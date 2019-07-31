#!/bin/bash -e

echo " Start compile OpenBlas (will take ~5 min)"

cd /data/commons/MULTICOM_db_tools//tools

cd OpenBLAS

#make clean

make

make PREFIX=/data/commons/MULTICOM_db_tools//tools/OpenBLAS install

echo "installed" > /data/commons/MULTICOM_db_tools//tools/OpenBLAS/install.done

