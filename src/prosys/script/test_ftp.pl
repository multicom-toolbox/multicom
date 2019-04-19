

$ftp = "/home/casp13/MULTICOM_package/software/prosys/script/autoftp";
-f $ftp || die "can't find ftp script.\n";

#get the latest list of pdb
print "connect rcsb pdb database....\n";
##system("$ftp -l  -u anonymous -p anonymous \'ftp.rcsb.org;./pub/pdb/data/structures/all/pdb\' > $prosys_db_stat_dir/pdblist.txt"); 
print("$ftp -l  -u anonymous -p anonymous \'ftp.wwpdb.org;./pub/pdb/data/structures/all/pdb\' > /home/casp13/MULTICOM_package/software/prosys_database/dbstat/pdblist.txt");
system("$ftp -l  -u anonymous -p anonymous \'ftp.wwpdb.org;./pub/pdb/data/structures/all/pdb\' > /home/casp13/MULTICOM_package/software/prosys_database/dbstat/pdblist.txt"); 
