export GPUARRAY_FORCE_CUDA_DRIVER_LOAD=""
export HDF5_USE_FILE_LOCKING=FALSE

if [ $# != 5 ]; then
	echo "$0 <target> <fasta> <hhsuite_dir> <dist_map> <output_directory> "
	exit
fi

ROOT=$(dirname $0)
target=$1
fasta=$2
hhsuite_dir=$3
dist_map=$4
outdir=$5
##GLOBAL_FLAG
global_dir=/storage/htc/bdm/tianqi/MULTICOM2/disrank//
modeller_dir=/storage/htc/bdm/tianqi/MULTICOM2/tools/modeller-9.16/
databases=/storage/htc/bdm/tianqi/MULTICOM2/databases/RCSB_PDB/atom/
## ENV_FLAG
source /storage/htc/bdm/tianqi/MULTICOM2/tools/distrank/env/distrank_virenv/bin/activate

model_dir=$outdir/hhusite_out
output_dir=$outdir/temp_rank
#dist_map=/exports/store2/casp14/tools/distrank/example/real_dist_agr/$target.txt
#fasta=/exports/store2/casp14/test/hhsuite_100/fasta/$target.fasta
#hhsuite_dir=/exports/store2/casp14/test/hhsuite_100/test/$target/hhsuite

python $ROOT/src/hhsuite_local2model.py -f $fasta -hs $hhsuite_dir -db  $databases -out $model_dir
python $ROOT/src/template_rank.py -m $model_dir -d $dist_map -f $fasta -o $output_dir
python $ROOT/src/template_model.py -t $target -r $output_dir/rank.txt -p $model_dir/hhsuite_orig -db $databases -m $modeller_dir -o $output_dir/model




