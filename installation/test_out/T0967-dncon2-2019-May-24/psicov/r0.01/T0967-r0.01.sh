#!/bin/bash
touch T0967-r0.01.running
echo "running T0967-r0.01 .."
date
/home/casp14/MULTICOM_TS/multicom/tools/DNCON2/psicov21/psicov21 -z 8 -o -r 0.01 T0967.aln > T0967-r0.01.psicov
if [ -s "T0967-r0.01.psicov" ]; then
   mv T0967-r0.01.running T0967-r0.01.done
   echo "T0967-r0.01 job done."
   date
   exit
fi
mv T0967-r0.01.running T0967-r0.01.failed
echo "psicov job T0967-r0.01 failed!"
date
