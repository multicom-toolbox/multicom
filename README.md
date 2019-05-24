# multicom
updating

#### (1) Download MULTICOM package

```
cd /home/MULTICOM_TS
git clone https://github.com/multicom-toolbox/multicom
cd multicom
```

#### (2) Download the database (required)
```
wget MULTICOM_db_tools.tar.gz (contact us)
```
#### (3) Configure MULTICOM system (required)

```
a. edit configure.pl

b. set the path of variable '$multicom_db_tools_dir' for multicom databases and tools (i.e., /home/MULTICOM_db_tools/).

c. save configure.pl

perl configure.pl
```

#### (4) Mannally configure tools (required)

```
cd installation/MULTICOM_manually_install_files
# one-time installation. If the path is same as before, the configurations can be skipped.


$ sh ./P1_install_boost.sh (take ~20 min)

$ sh ./P2_install_OpenBlas.sh  (take ~1 min)

$ sh ./P3_install_freecontact.sh (take ~1 min)

$ sh ./P4_install_scwrl4.sh (take ~1 min, please copy the path provided by program for scwrl installation)

$ sh ./P5_python_virtual.sh (take ~1 min)
```

#### (5) Testing the MULTICOM tools (recommended)


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

```


**(6) Run MULTICOM for structure predicton**

```
   Usage:
   $ sh bin/run_multicom.sh <file name>.fasta  <output folder>

   Example:
   $ sh bin/run_multicom.sh examples/T0993s2.fasta test_out/T0993s2_out
```

(2) Predicting multiple proteins:

```
   Usage:
   $ perl run_DNSS2.pl -indir <input directory> -out <output directory>

   Example:
   $ source ~/python_virtualenv_DNSS2/bin/activate
   $ perl run_DNSS2.pl -indir ./test/ -out ./output/
```
