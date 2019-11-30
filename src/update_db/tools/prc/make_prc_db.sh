#!/bin/sh

if [ $# -ne 1 ]
then
        echo "need one parameters: databasae directory."
        exit 1
fi

database_path=$1


if [ ! -d "$database_path/prc_db" ]; then
  mkdir $database_path/prc_db
fi


/home/jhou4/tools/multicom/src/update_db/tools/prc/make_prc_db.pl $database_path /home/jhou4/tools/multicom/tools/sam3.5.x86_64-linux/ $database_path/prc_db/ prcdb.lib

