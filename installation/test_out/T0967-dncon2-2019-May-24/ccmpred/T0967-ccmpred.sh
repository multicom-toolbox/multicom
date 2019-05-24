#!/bin/bash
touch ccmpred.running
echo "running ccmpred .."
/home/casp14/MULTICOM_TS/multicom/tools/DNCON2/CCMpred/bin/ccmpred -t 8 T0967.aln T0967.ccmpred > ccmpred.log
if [ -s "T0967.ccmpred" ]; then
   mv ccmpred.running ccmpred.done
   echo "ccmpred job done."
   exit
fi
echo "ccmpred failed!"
mv ccmpred.running ccmpred.failed
