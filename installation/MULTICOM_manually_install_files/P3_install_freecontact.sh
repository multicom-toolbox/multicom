#!/bin/bash -e

echo " Start compile freecontact (will take ~1 min)"

cd /storage/tools/MULTICOM_db_tools//tools/DNCON2

cd freecontact-1.0.21

autoreconf -f -i

#make clean

./configure --prefix=/storage/tools/MULTICOM_db_tools//tools/DNCON2/freecontact-1.0.21 LDFLAGS="-L/storage/tools/MULTICOM_db_tools//tools/OpenBLAS/lib -L/storage/tools/MULTICOM_db_tools//tools/boost_1_55_0/lib" CFLAGS="-I/storage/tools/MULTICOM_db_tools//tools/OpenBLAS/include -I/storage/tools/MULTICOM_db_tools//tools/boost_1_55_0/include"  CPPFLAGS="-I/storage/tools/MULTICOM_db_tools//tools/OpenBLAS/include -I/storage/tools/MULTICOM_db_tools//tools/boost_1_55_0/include" --with-boost=/storage/tools/MULTICOM_db_tools//tools/boost_1_55_0/

make

make install

if [[ -f "bin/freecontact" ]]; then
	echo "bin/freecontact exists"
	echo "installed" > /storage/tools/MULTICOM_db_tools//tools/DNCON2/freecontact-1.0.21/install.done

else

	echo "bin/freecontact doesn't exist, check the installation"
fi

