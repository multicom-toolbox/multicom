#!/bin/sh

#./hhblits/bin/hhblits -i T0579 -d /disk2/chengji/nr20/nr20_11Jan10 

#./hhblits/bin/hhblits -i T0579 -d /disk2/chengji/pdb/pdb70_24Nov11


./hhblits/bin/hhblits -i T0579 -d /disk2/chengji/nr20/nr20_11Jan10 -oa3m T0579.a3m

./hhblits/scripts/addss.pl T0579.a3m T0579.ss.a3m -a3m

./hhblits/bin/hhmake -i T0579.ss.a3m -o T0579.hmm

#./hhblits/bin/hhblits -i T0579.a3m -d /disk2/chengji/pdb/pdb70_24Nov11 
#./hhblits/bin/hhblits -i T0579.ss.a3m -d /disk2/chengji/nr20/nr20_11Jan10

#./hhblits/bin/hhsearch -i T0579.hmm -d /home/chengji/casp8/hhpred/hhpreddb 

################################################################################################################
#Develop a systems that generate two kinds of alignments and two kinds of models

./hhblits/bin/hhsearch -i T0579.hmm -d /home/chengji/casp8/hhpred/hhpreddb -realign -mact 0 > T0579.local

./hhblits/bin/hhsearch -i T0579.hmm -d /home/chengji/casp8/hhpred/hhpreddb -realign -global > T0579.global

#################################################################################################################
