#!/bin/sh
#~/software/prosys/script/update_main.pl db_option > update.log
#~/software/prosys/script/update_main.pl db_option > update.log
~/software/prosys/script/update_main.pl db_option > update.log

#update compass database
~/casp8/compass/script/build_compass_db.pl ~/software/new_compass/compass_search/mk_compass_db /home/chengji/software/prosys_database/library/ /home/chengji/software/prosys_database/fr_lib/sort90 ~/casp8/compass/database/compass_db_new

mv ~/casp8/compass/database/compass_db ~/casp8/compass/database/compass_db_old
mv ~/casp8/compass/database/compass_db_new ~/casp8/compass/database/compass_db

