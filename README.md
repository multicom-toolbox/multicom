# The MULTICOM protein structure system. 
This repository include the source code and documents of both template-based and template-free modeling of the MULTICOM protein structure prediction system. 1D feature prediction, contact prediction, and clustering-based model ranking programs are also included.

Web service: http://sysbio.rnet.missouri.edu/multicom_cluster/

(We are currently updating mutlicom2.0)

**(1) Download MULTICOM package (short path is recommended)**

```
cd /home/MULTICOM_TS
git clone https://github.com/multicom-toolbox/multicom.git
cd multicom
```

**(2) Setup the tools and download the database (required)**

```
a. edit method.list

    uncomment the methods that you would like to run in MULTICOM system (i.e., DNCON2, HHsearch, CONFOLD) 

b. edit 'setup_database.pl' and 'setup_database_64bit.pl'

    set the path of variable '$multicom_db_tools_dir' for multicom databases and tools (i.e., /home/MULTICOM_db_tools/).

c(1). Install 32bit tools: perl setup_database.pl
c(2). Or Install 64bit tools: perl setup_database_64bit.pl

Note: current package requires ~1T space to install complete version due to many large sequence/profile databases and tools requried by this system. The package optimization is in process.
```

Please refer to 'cite_methods_for_publication.txt' to cite the methods that you use in MULTICOM system for publication. The tools can be also downloaded from their official websites.



**(3) Configure MULTICOM system (required)**

```
a. edit configure.pl

b. set the path of variable '$multicom_db_tools_dir' for multicom databases and tools (i.e., /home/MULTICOM_db_tools/).

c. save configure.pl

perl configure.pl
```

**Note: Boosting and freecontact may fail to be installed completely on different system versions. We tested on Redhat 6.9 with gcc 4.4 and Cent OS 7.6 with gcc 4.8.5. Please verify if freecontact can run correctly using following test program:**
```
sh ./tools/DNCON2/test_freecontact.sh

Output:
1 D 2 I 0.229506 2.14777
1 D 3 Y 0.170497 0.725349
1 D 4 G 0.111352 0.262319
1 D 5 D 0.0955716 0.426977
1 D 6 E 0.0803633 -0.125561
1 D 7 I 0.0956117 0.310092
1 D 8 T 0.0789781 -0.119555
1 D 9 A 0.079003 0.0613284
1 D 10 V 0.0922035 -0.223796
```
If the output reports any warning or error, you can also manually inspect the installation in folder 'installation/MULTICOM_manually_install_files/' or contact us.


**(4) Set theano as backend for keras (required)**

Change the contents in '~/.keras/keras.json'. DNCON2 is currently running based on theano-compiled models.
```
$ mkdir ~/.keras
$ vi ~/.keras/keras.json


{
    "epsilon": 1e-07,
    "floatx": "float32",
    "image_data_format": "channels_last",
    "backend": "theano"
}
```

**(5) Testing the individual tools in MULTICOM (recommended)**

```
cd installation/MULTICOM_test_codes

   
a. Sequential testing 
    perl test_multicom_all_parallel.pl
  
b. Parallel tesing up to 5 jobs at same time
    perl test_multicom_all_parallel.pl 5
    
```

**(6) Validate the individual predictons**

```

cd installation/MULTICOM_test_codes
sh T99-run-validation.sh

```

**(7) Testing the integrated MULTICOM system (recommended)**

```

cd examples
sh T0-run-multicom-T1006.sh
sh T0-run-multicom-hard-T0957s2.sh

```

**(8) Run MULTICOM for structure predicton**

```
   Usage:
   $ sh bin/run_multicom.sh <target id> <file name>.fasta  <output folder>

   Example:
   $ sh bin/run_multicom.sh T0993s2 examples/T0993s2.fasta test_out/T0993s2_out
```

**(9) Run individual methods for structure predicton**

```
Examples:
   hhsearch:
   $ sh bin/P1-run-hhsearch.sh <target id> <file name>.fasta  <output folder>
   
   dncon2:
   $ sh bin/P4-run-dncon2.sh <target id> <file name>.fasta  <output folder>

   hhsuite:
   $ sh bin/P11-run-hhsuite.sh <target id> <file name>.fasta  <output folder>

   hhblits3:
   $ sh bin/P24-run-hhblits3.sh <target id> <file name>.fasta  <output folder>

   confold:
   $ sh bin/P27-run-confold.sh <target id> <file name>.fasta  <output folder>

```
