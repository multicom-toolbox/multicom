# multicom
updating

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

```
cd installation/MULTICOM_manually_install_files

# one-time installation. If the path is same as before, the configurations can be skipped.


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

**(6) Testing the MULTICOM tools (recommended)**


```
cd installation/MULTICOM_test_codes

ls

sh T1-run-pspro2.sh

sh T2-run-SCRATCH.sh

sh T4-run-dncon2.sh 

sh T5-run-modeller9.16.sh

sh T7-run-hhsearch.sh

sh T11-run-hhsuite.sh

sh T14-run-psiblast.sh

sh T15-run-compass.sh

sh T17-run-prc.sh

sh T20-run-raptorx.sh

sh T27-run-confold.sh

sh T28-run-unicon3d.sh

```

**(7) Validate predictons**
```
cd installation/MULTICOM_test_codes
sh T99-run-validation.sh
```

**(8) Run MULTICOM for structure predicton**

```
   Usage:
   $ sh bin/run_multicom.sh <file name>.fasta  <output folder>

   Example:
   $ sh bin/run_multicom.sh examples/T0993s2.fasta test_out/T0993s2_out
```

