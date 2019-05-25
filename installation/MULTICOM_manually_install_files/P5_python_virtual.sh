#!/bin/bash -e

echo " Start install python virtual environment (will take ~1 min)
"

cd /data/commons/MULTICOM_db_tools//tools

rm -rf python_virtualenv

virtualenv python_virtualenv

source /data/commons/MULTICOM_db_tools//tools/python_virtualenv/bin/activate

pip install --upgrade pip

pip install --upgrade numpy==1.12.1

pip install --upgrade keras==1.2.2

pip install --upgrade theano==0.9.0

pip install --upgrade h5py

pip install --upgrade matplotlib

NOW=$(date +"%m-%d-%Y")

cp ~/.keras/keras.json ~/.keras/keras.json.$NOW.$RANDOM

cp /home/jh7x3/multicom//installation/MULTICOM_configure_files/keras_multicom.json ~/.keras/keras.json

