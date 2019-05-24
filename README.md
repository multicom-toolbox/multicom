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

$ sh ./P4_install_scwrl4.sh (take ~1 min)

$ sh ./P5_python_virtual.sh (take ~1 min)
```

#### (5) Testing the MULTICOM tools (recommended)

```
cd installation/MULTICOM_test_codes

ls

sh T1-run-pspro2.sh

sh T2-run-SCRATCH.sh

sh T5-run-modeller9.16.sh

sh T7-run-hhsearch.sh
```
