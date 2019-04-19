#!/bin/sh

./stx_model_comb.pl ~/software/tm_score/TMscore_32 ./0285/ ../model_eva/score_T0285 ../casp7_sequences/T0285 ./pir/T0285.pir 1.5 40 0.5

mkdir comb_T0285

./pir2ts_energy.pl ~/software/prosys/modeller7v7/ ~/casp8/model_cluster/0285/ comb_T0285 ./pir/T0285.pir  3

#echo "do model combination..."
#./stx_model_comb.pl ~/software/tm_score/TMscore_32 ./0284/ ../model_eva/score_T0284 ../casp7_sequences/T0284 ./pir/T0284.pir 1.5 40 0.5

#mkdir comb_T0284

#echo "generate model..."
#./pir2ts_energy.pl ~/software/prosys/modeller7v7/ ~/casp8/casp7_models/0284/ comb_T0284 ./pir/T0284.pir  3


