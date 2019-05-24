#!/bin/bash
touch T0967-r0.001.running
echo "running T0967-r0.001 .."
date
/home/casp14/MULTICOM_TS/multicom/tools/DNCON2/psicov21/psicov21 -z 8 -o -r 0.001 T0967.aln > T0967-r0.001.psicov
if [ -s "T0967-r0.001.psicov" ]; then
   mv T0967-r0.001.running T0967-r0.001.done
   echo "T0967-r0.001 job done."
   date
   exit
fi
mv T0967-r0.001.running T0967-r0.001.failed
echo "psicov job T0967-r0.001 failed!"
date
