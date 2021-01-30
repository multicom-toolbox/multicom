import os
import numpy as np
import shutil

# seq_list_file = "/mnt/data/zhiye/Python/DNCON4/data/CASP13/lists-test-train/test.lst"
# fasta_folder = '/mnt/data/zhiye/Python/DNCON4/data/CASP13/fasta/'
seq_list_file = "/mnt/data/zhiye/Python/DNCON4_db_tools/features/CASP12//test.lst"
fasta_folder = '/mnt/data/zhiye/Python/DNCON4_db_tools/features/CASP12//fasta/'
# seq_list_file = '/mnt/data/zhiye/Python/DNCON4_db_tools/features/CASP13_DM/lists-test-train/test.lst'
# fasta_folder = '/mnt/data/zhiye/Python/DFOLD-master/examples/dm_fasta/'
model_dir = ['/mnt/data/zhiye/Python/DNCON4/architecture_distance/Test/DeepHBond/casp12/aln/', 
'/mnt/data/zhiye/Python/DNCON4/architecture_distance/Test/DeepHBond/casp12/msa/']
ensemble_dir = '/mnt/data/zhiye/Python/DNCON4/architecture_distance/Test/DeepHBond/casp12/ensemble/'	
if_generate_rr = False

def chkdirs(fn):
	dn = os.path.dirname(fn)
	if not os.path.exists(dn): os.makedirs(dn)

model_num = len(model_dir)

# ensemble real dist and generate dist rr
ensemble_sub_dir =  '/pred_map_ensem/'

sum_cmap_dir = ensemble_dir
rr_folder = sum_cmap_dir + '/rr/'
chkdirs(sum_cmap_dir)
chkdirs(rr_folder)
f = open(seq_list_file, 'r')
for line in f.readlines():
	single_line = line.strip('\n')
	seq_name = single_line
	print('ensemble contact map ', seq_name)

	sum_map_filename = sum_cmap_dir + seq_name + '.txt'
	sum_map = 0
	for i in range(model_num):
		cmap_file = model_dir[i] + ensemble_sub_dir + seq_name + '.txt'
		cmap = np.loadtxt(cmap_file, dtype=np.float32)
		sum_map += cmap
	sum_map /= model_num
	np.savetxt(sum_map_filename, sum_map, fmt='%.4f')

	if if_generate_rr:
		rr_file = rr_folder + seq_name + '.rr'
		fasta = open(fasta_folder + seq_name + '.fasta', 'r').readlines()[1]
		with open(rr_file, "a") as myfile:
			myfile.write(str(fasta))
		
		L = sum_map.shape[0]
		for i in range(0, L):
			for j in range(i + 1, L):  # for confold2, j = i+5 for dfold j= i+2
				str_to_write = str(i + 1) + " " + str(j + 1) + " 0 8 " + str(sum_map[i][j]) + "\n"
				with open(rr_file, "a") as myfile:
					myfile.write(str_to_write)
