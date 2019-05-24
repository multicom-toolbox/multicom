#!/bin/bash
touch hhb-cov60.running
echo "running hhblits job hhb-cov60.."
/home/casp14/MULTICOM_TS/multicom/tools/DNCON2/hhsuite-2.0.16-linux-x86_64/bin/hhblits -i T0967.fasta -d /home/casp14/MULTICOM_TS/multicom/databases/hhsuite3_dbs/uniprot20_2016_02/uniprot20_2016_02 -oa3m hhb-cov60.a3m -cpu 2 -n 3 -maxfilt 500000 -diff inf -e 0.001 -id 99 -cov 60 > hhb-cov60-hhblits.log
if [ ! -f "hhb-cov60.a3m" ]; then
   mv hhb-cov60.running hhb-cov60.failed
   echo "hhblits job hhb-cov60 failed!"
   exit
fi
egrep -v "^>" hhb-cov60.a3m | sed 's/[a-z]//g' > hhb-cov60.aln
if [ -f "hhb-cov60.aln" ]; then
   mv hhb-cov60.running hhb-cov60.done
   echo "hhblits hhb-cov60 job done."
   exit
fi
echo "Something went wrong! hhb-cov60.aln file not present!"
mv hhb-cov60.running hhb-cov60.failed
