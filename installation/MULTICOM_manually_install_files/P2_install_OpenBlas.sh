#!/bin/bash -e

echo " Start compile OpenBlas (will take ~5 min)"

cd /storage/htc/bdm/tools/multicom_db_tools//tools

cd OpenBLAS

#make clean

make

make PREFIX=/storage/htc/bdm/tools/multicom_db_tools//tools/OpenBLAS install

echo "installed" > /storage/htc/bdm/tools/multicom_db_tools//tools/OpenBLAS/install.done

