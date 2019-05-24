#!/bin/bash
echo "Start Time:date"
SECONDS=0
echo "Starting DeepSF modeling.."
rm -f /home/casp13/MULTICOM_package/casp8/deepsf/test/T0579_2/deepsf_stage1/T0579-hhm/T0579/ECOD_H_fold_X.10.1_top10_for_modeling_pir_dir/modeling.done
rm -f /home/casp13/MULTICOM_package/casp8/deepsf/test/T0579_2/deepsf_stage1/T0579-hhm/T0579/ECOD_H_fold_X.10.1_top10_for_modeling_pir_dir/modeling.failed
perl /home/casp13/deepsf_3d//scripts/pir2ts_energy_9v16_deepsf_batch.pl  /home/casp13/MULTICOM_package/casp8/deepsf/test/T0579_2/deepsf_stage1/T0579-hhm/T0579/ECOD_H_fold_X.10.1_top10_for_modeling_pir_dir/ /home/casp13/MULTICOM_package/casp8/deepsf/test/T0579_2/deepsf_stage1/T0579-hhm/T0579/atoms 1 T0579
duration=$SECONDS
echo "DeepSF modeling: $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
if [ -s "/home/casp13/MULTICOM_package/casp8/deepsf/test/T0579_2/deepsf_stage1/T0579-hhm/T0579/ECOD_H_fold_X.10.1_top10_for_modeling_pir_dir/modeling.done" ]; then
    touch /home/casp13/MULTICOM_package/casp8/deepsf/test/T0579_2/deepsf_stage1/T0579-hhm/T0579/ECOD_H_fold_X.10.1_top10_for_modeling_pir_dir.modeling.done
else
    touch /home/casp13/MULTICOM_package/casp8/deepsf/test/T0579_2/deepsf_stage1/T0579-hhm/T0579/ECOD_H_fold_X.10.1_top10_for_modeling_pir_dir.modeling.failed
fi
date
