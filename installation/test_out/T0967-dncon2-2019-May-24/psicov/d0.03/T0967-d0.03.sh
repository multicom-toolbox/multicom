#!/bin/bash
touch T0967-d0.03.running
echo "running T0967-d0.03 .."
date
/home/casp14/MULTICOM_TS/multicom/tools/DNCON2/psicov21/psicov21 -z 8 -o -d 0.03 T0967.aln > T0967-d0.03.psicov
if [ -s "T0967-d0.03.psicov" ]; then
   mv T0967-d0.03.running T0967-d0.03.done
   echo "T0967-d0.03 job done."
   date
   exit
fi
mv T0967-d0.03.running T0967-d0.03.failed
echo "psicov job T0967-d0.03 failed!"
date
