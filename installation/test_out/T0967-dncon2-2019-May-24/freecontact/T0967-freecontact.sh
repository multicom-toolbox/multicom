#!/bin/bash
touch freecontact.running
echo "running freecontact .."
/home/casp14/MULTICOM_TS/multicom/tools/DNCON2/freecontact-1.0.21/bin/freecontact < T0967.aln > T0967.freecontact.rr
if [ -s "T0967.freecontact.rr" ]; then
   mv freecontact.running freecontact.done
   echo "freecontact job done."
   exit
fi
echo "freecontact failed!"
mv freecontact.running freecontact.failed
