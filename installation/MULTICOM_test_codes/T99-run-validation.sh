#!/bin/bash

cd /home/jh7x3/multicom/test_out/ 
source /home/jh7x3/multicom/tools/python_virtualenv/bin/activate
perl /home/jh7x3/multicom/installation/scripts/validate_predictions.pl  T1006  /home/jh7x3/multicom/test_out/ /home/jh7x3/multicom/installation/benchmark/TBM
