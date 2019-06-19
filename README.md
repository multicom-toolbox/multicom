# The MULTICOM protein structure system. 
This repository include the source code and documents of both template-based and template-free modeling of the MULTICOM protein structure prediction system. 1D feature prediction, contact prediction, and clustering-based model ranking programs are also included.

Web service: http://sysbio.rnet.missouri.edu/multicom_cluster/

(We are currently updating mutlicom2.0)

**(1) Download MULTICOM package (short path is recommended)**

```
cd /home/MULTICOM_TS
git clone https://github.com/multicom-toolbox/multicom
cd multicom
```

**(2) Download the database (required)**
```
wget MULTICOM_db_tools.tar.gz (contact us)
```
**(3) Configure MULTICOM system (required)**

```
a. edit configure.pl

b. set the path of variable '$multicom_db_tools_dir' for multicom databases and tools (i.e., /home/MULTICOM_db_tools/).

c. save configure.pl

perl configure.pl
```

**(4) Mannally configure tools (required)**

***one-time installation. If the path is same as before, the configurations can be skipped.
```
cd installation/MULTICOM_manually_install_files

$ sh ./P1_install_boost.sh 
(** may take ~20 min)

$ sh ./P2_install_OpenBlas.sh 
(** take ~1 min)

$ sh ./P3_install_freecontact.sh 
(** take ~1 min)

$ sh ./P4_install_scwrl4.sh 
(** take ~1 min, after running this shell file, the installation path for scwrl will be reported in the second line. 
Please copy the provided path for scwrl installation)

$ sh ./P5_python_virtual.sh 
(** take ~1 min)
```

**(5) Set theano as backend for keras (required)**

Change the contents in '~/.keras/keras.json'. DNCON2 is currently running based on theano-compiled models.
```
$ vi ~/.keras/keras.json


{
    "epsilon": 1e-07,
    "floatx": "float32",
    "image_data_format": "channels_last",
    "backend": "theano"
}
```

**(6) Testing the individual tools in MULTICOM (recommended)**

```
cd installation/MULTICOM_test_codes

   
a. Sequential testing 
    perl test_multicom_all_parallel.pl
  
b. Parallel tesing up to 5 jobs at same time
    perl test_multicom_all_parallel.pl 5
    
```

**(7) Validate the individual predictons**

```

cd installation/MULTICOM_test_codes
sh T99-run-validation.sh

```

**(8) Testing the integrated MULTICOM system (recommended)**

```

cd examples
sh T0-run-multicom-T1006.sh
sh T0-run-multicom-hard-T0957s2.sh

```

**(9) Run MULTICOM for structure predicton**

```
   Usage:
   $ sh bin/run_multicom.sh <target id> <file name>.fasta  <output folder>

   Example:
   $ sh bin/run_multicom.sh T0993s2 examples/T0993s2.fasta test_out/T0993s2_out
```

