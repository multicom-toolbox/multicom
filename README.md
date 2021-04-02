# The MULTICOM2 protein structure system. 
This repository include the source code and documents of both template-based and template-free modeling of the MULTICOM2 protein structure prediction system. 

Note: current package requires **~430G** space to install complete version due to many large sequence/profile databases and tools requried by this system.

**(1) Download MULTICOM2 package (short path is recommended)**

```
git clone --branch multicom_v2.0 https://github.com/multicom-toolbox/multicom.git
cd multicom
```

**(2) Download tools database and configure MULTICOM2 system(required)**

```
python setup.py

python configure.py

```

**(3) Download trRosetta package manually(optional)**


The trRosetta package(trRosetta.tar.bz2) needs to be downloaded at  <http://yanglab.nankai.edu.cn/trRosetta/download/> and installed under the folder **multicom/tools/trRosetta/**


Please refer to **cite_methods_for_publication.txt** to cite the methods that you use in MULTICOM2 system for publication. The tools can be also downloaded from their official websites.

**(4) Run MULTICOM for structure predicton**

```
   Usage:
   $ mkdir <output folder>
   $ sh bin/run_multicom.sh <file name>.fasta  <output folder>

   Example:
   $ cd examples
   $ mkdir 3e7u
   $ sh ../bin/run_multicom2.sh 3e7u.fasta 3e7u
```

**(5) Testing the individual predictor in MULTICOM2 (recommended)**
```
Examples:
   cd examples
   hmmer3:
   $ sh ../bin/P9-run-hmmer3.sh <target id> <file name>.fasta  <output folder>

   hhsuite:
   $ sh ../bin/P4-run-hhsuite.sh <target id> <file name>.fasta  <output folder>

   psibalst:
   $ sh ../bin/P8-run-psibalst.sh <target id> <file name>.fasta  <output folder>

   DeepDist:
   $ sh ../bin/P15-run-DeepDist.sh <target id> <file name>.fasta  <output folder>

```

**(6) Configuring multicom2 packing scripts(optional)**
```
cd src/pack_multicom/
python configure.py

# Use your own python environment or the python environment in tools directory to install required packages
pip install -r requirements.txt

Usage:
    # activate your python environment first
    # Use full path for <workdir> and <outputdir>
    $ sh visualize_multicom_cluster/P1_organize_prediction_v2.sh <workdir> <target id> <outputdir>  
```

