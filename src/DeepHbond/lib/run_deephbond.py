# -*- coding: utf-8 -*-
"""
Created on Tue Feb 12 15:57:26 2020

@author: Zhiye
"""
import sys
import os,glob,re
import time
from multiprocessing import Process
from random import randint
import numpy as np
import subprocess
import argparse
import shutil

def is_dir(dirname):
	"""Checks if a path is an actual directory"""
	if not os.path.isdir(dirname):
		msg = "{0} is not a directory".format(dirname)
		raise argparse.ArgumentTypeError(msg)
	else:
		return dirname

def is_file(filename):
	"""Checks if a file is an invalid file"""
	if not os.path.exists(filename):
		msg = "{0} doesn't exist".format(filename)
		raise argparse.ArgumentTypeError(msg)
	else:
		return filename

def chkdirs(fn):
	'''create folder if not exists'''
	dn = os.path.dirname(fn)
	if not os.path.exists(dn): os.makedirs(dn)

def run_shell_file(filename):
	outfile = filename.split('.')[0] + '.out'
	if not os.path.exists(filename): 
		print("Shell file not exist: %s, please check!"%filename)
		sys.exit(1)
	print("parent %s,child %s,name: %s"%(os.getppid(),os.getpid(),filename))
	os.chdir(os.path.dirname(filename))
	os.system('./%s > %s'%(os.path.basename(filename), outfile))

def cut_domain_fasta(fasta_name, outdir, dm_index_file):
	fasta = open(outdir + '/' + fasta_name + '.fasta', 'r').readlines()[1].strip('\n')
	fl_len = len(fasta)
	dm_name_dict = {}
	f = open(dm_index_file, 'r')
	for line in f.readlines():
		if line == '\n':
			continue
		line_list = line.strip('\n').split(' ')
		index_info = line_list[1]
		# insertion 
		dm_index_insert=[]
		if '-' in line_list[2]:
			dm_index_insert = line_list[2].split('-')
		dm_num = index_info.split(':')[0]
		dm_index = index_info.split(':')[-1].split('-')
		dm_fasta_name = fasta_name + '-D' + str(int(dm_num)+1)
		dm_name_dict[dm_fasta_name] = dm_index + dm_index_insert
		dm_fasta_file = outdir + '/' + dm_fasta_name + '.fasta'
		if os.path.exists(dm_fasta_file) and os.path.getsize(dm_fasta_file) != 0:
			continue
		dm_fasta = fasta[int(dm_index[0])-1:int(dm_index[1])]
		if dm_index_insert != []:
			dm_fasta_insert = fasta[int(dm_index_insert[0])-1:int(dm_index_insert[1])]
			dm_fasta = dm_fasta + dm_fasta_insert
		dm_len = len(dm_fasta)
		if dm_len >= fl_len:
			return False
		fisrt_line = '>' + dm_fasta_name + '\n'
		print("Cut domain fasta out: %s"%dm_fasta_name)
		f = open(dm_fasta_file, 'w')
		f.write(fisrt_line)
		f.write(dm_fasta)
		f.close()
		# with open(dm_fasta_file, 'a') as myfile:
		# 	myfile.write(fisrt_line)
		# 	myfile.write(dm_fasta)
	return dm_name_dict


def combine_dm_fl(full_length_dir, domain_dir_dict, dm_name_dict):
	fl_map_folder = full_length_dir + '/ensemble/'
	combine_folder = full_length_dir + '/ensemble/'
	for domain_name in dm_name_dict:	
		print('Combine %s'% domain_name)
		full_name = domain_name.split('-')[0]
		dm_map_folder = domain_dir_dict[domain_name] + '/ensemble/'

		domain_start = int(dm_name_dict[domain_name][0])-1
		domain_end = int(dm_name_dict[domain_name][1])
		insertion_flag = False
		if len(dm_name_dict[domain_name]) > 2: #insertion
			insertion_flag = True
			domain_start_1 = int(dm_name_dict[domain_name][2])-1
			domain_end_1 = int(dm_name_dict[domain_name][3])

		domain_file = dm_map_folder + domain_name + '.txt'
		full_file = fl_map_folder + full_name +'.txt'
		combine_file = combine_folder + '/pred_map_ensem_dm/' + full_name + '.txt'
		chkdirs(combine_file)

		if not os.path.exists(domain_file) or not os.path.exists(full_file):
			print("Domain or full map not exists, please check!%s %s"%(domain_file, full_file))
			continue
		# for multi-domain in one map
		if os.path.exists(combine_file):
			full_map = np.loadtxt(combine_file)
		else:
			full_map = np.loadtxt(full_file)
		domain_map = np.loadtxt(domain_file)
		L = full_map.shape[0]
		enmpty_map = np.zeros((L, L))
		if insertion_flag == False:
			enmpty_map[domain_start:domain_end, domain_start:domain_end] = domain_map
			full_map[enmpty_map > full_map] = enmpty_map [enmpty_map > full_map]
		else:
			enmpty_map[domain_start:domain_end, domain_start:domain_end] = domain_map[:(domain_end-domain_start), :(domain_end-domain_start)]
			enmpty_map[domain_start_1:domain_end_1, domain_start_1:domain_end_1] = domain_map[(domain_end-domain_start):, (domain_end-domain_start):]

			enmpty_map[domain_start:domain_end, domain_start_1:domain_end_1] = domain_map[:(domain_end-domain_start), (domain_end-domain_start):]
			enmpty_map[domain_start_1:domain_end_1, domain_start:domain_end] = domain_map[(domain_end-domain_start):, :(domain_end-domain_start)]

			full_map[enmpty_map > full_map] = enmpty_map [enmpty_map > full_map]

		np.savetxt(combine_file, full_map, fmt='%.4f')
	return combine_folder+'/pred_map_ensem_dm/'

def ensemble_aln_msa(fasta_name, outdir):
	model_dir = [outdir + '/aln/', outdir + '/msa/']
	ensemble_dir = outdir + '/ensemble/'
	model_num = len(model_dir)
	chkdirs(ensemble_dir)
	ensemble_child_dir =  '/pred_map_ensem/'
	sum_cmap_dir = ensemble_dir
	chkdirs(sum_cmap_dir)

	seq_name = fasta_name
	print('ensemble ', seq_name)

	sum_map_filename = sum_cmap_dir + seq_name + '.txt'
	sum_map = 0
	for i in range(model_num):
		cmap_file = model_dir[i] + ensemble_child_dir + seq_name + '.txt'
		cmap = np.loadtxt(cmap_file, dtype=np.float32)
		sum_map += cmap
	sum_map /= model_num
	np.savetxt(sum_map_filename, sum_map, fmt='%.4f')

	return ensemble_dir

def generate_hhbond_for_dfold(fasta_name, outdir, ensem_dir):
	hhbonds_folder = ensem_dir + '/hhbonds/'
	chkdirs(hhbonds_folder)
	hhbonds_file = hhbonds_folder + fasta_name + '.hhbonds'
	if os.path.exists(hhbonds_file):
		os.remove(hhbonds_file)
	fasta = open(outdir + '/' + fasta_name + '.fasta', 'r').readlines()[1].strip('\n')
	with open(hhbonds_file, "a") as myfile:
		myfile.write(str(fasta))
		myfile.write('\n')
	hmap = np.loadtxt(ensem_dir + '/' + fasta_name + '.txt')
	L = hmap.shape[0]
	for i in range(0, L):
		for j in range(i + 1, L):  # for confold2, j = i+5 for dfold j= i+2
				str_to_write = str(i + 1) + " " + str(j + 1) + " 0 3.5 " + '%.4f'%(hmap[i][j]) + "\n"
				with open(hhbonds_file, "a") as myfile:
					myfile.write(str_to_write)
	return hhbonds_file

def largest_indices(ary, n):
	"""Returns the n largest indices from a numpy array."""
	flat = ary.flatten()
	indices = np.argpartition(flat, -n)[-n:]
	indices = indices[np.argsort(-flat[indices])]
	return np.unravel_index(indices, ary.shape)

def get_topnL_hhbonds(src_file, n = 1):
	dst_file = os.path.dirname(src_file) + '/' +str(n) + 'L_' + os.path.basename(src_file)
	f = open(src_file, 'r')
	line = f.readline(5)
	if line.isalpha():
		src_hhbond = np.loadtxt(src_file, skiprows=1)
	else:
		src_hhbond = np.loadtxt(src_file)
	L = np.sqrt(src_hhbond.shape[0])
	thred = int(n*L)
	dst_hhbond = src_hhbond[np.argsort(-src_hhbond[:,-1])]
	dst_hhbond = dst_hhbond[0:thred,:]
	np.savetxt(dst_file, dst_hhbond, fmt='%i %i %i %.1f %.4f')
	return dst_file

def remove_similar(sort_i):
	sort_i = list(np.array(sort_i))
	new_list = []
	for i in sort_i:
		if sort_i.count(i) == 1: 
			new_list.append(i)
	return np.array(new_list)

def filter_hhbond(src_file):
	dst_file = os.path.dirname(src_file)+"/"+os.path.basename(src_file)+".filt"
	#hhbond filter
	if os.path.getsize(src_file) == 0:
		print("Hhbonds file is empty: %s , please check!\n"%src_file)
		sys.exit(1)
	hhbond_file = src_file
	fline=open(hhbond_file).readline().rstrip()
	if fline and fline[0].isalpha():
		src_map = np.loadtxt(hhbond_file,skiprows=1)
	else:
		src_map = np.loadtxt(hhbond_file)
	if src_map.ndim == 1:
		sort_i = np.sort(src_map[0])
		unique_i = [sort_i.tolist()]
	else:
		sort_i = np.sort(src_map[:,0])
		unique_i = remove_similar(sort_i)
	if len(unique_i) == 0:
		print("%s unique_i is empty\n"%src_file)
		return dst_file
	index_list_i = []
	for i in unique_i:
		if len(unique_i) == 1 and src_map.ndim == 1:
			index = np.argwhere(src_map[0] == i)
		else:
			index = np.argwhere(src_map[:,0] == i)
		index_list_i.append(int(index))
	if len(index_list_i) == 1 and src_map.ndim == 1:
		tmp_map = src_map[:]
	else:
		tmp_map = src_map[np.array(index_list_i),:]
	if src_map.ndim == 1:
		sort_j = np.sort(tmp_map[1])
		unique_j = [sort_j.tolist()]
	else:
		sort_j = np.sort(tmp_map[:,1])
		unique_j = remove_similar(sort_j)
	if len(unique_j) == 0:
		print("%s unique_j is empty\n"%src_file)
		return dst_file
	index_list_j = []
	for i in unique_j:
		if len(unique_j) == 1 and tmp_map.ndim == 1:
			index = np.argwhere(tmp_map[1] == i)
		else:
			index = np.argwhere(tmp_map[:,1] == i)
		index_list_j.append(int(index))
	if len(index_list_j) == 1 and src_map.ndim == 1:
		dst_map = tmp_map[:]
	else:
		dst_map = tmp_map[np.array(index_list_j),:]
	#write hhbond_filter to file
	g = open(dst_file,"w")
	if dst_map.ndim == 1:
		g.write(str(int(dst_map[0]))+" "+str(int(dst_map[1]))+" 0 3.5 "+str(float(dst_map[-1]))+"\n")
	else:
		for item in dst_map:
			i = int(item[0])
			j = int(item[1])
			g.write(str(i)+" "+str(j)+" 0 3.5 "+str(item[-1])+"\n")
	g.close()  
	return dst_file

def generate_hhbond_constrain(src_file, fasta_name, dst_dir = None):
	GLOABL_Path = os.path.dirname(sys.path[0])
	if os.path.getsize(src_file) == 0:
		print("Hhbonds file is empty: %s , skip generate hhbond constrain\n"%src_file)
		return False
	else:
		if dst_dir == None:
			os.system(GLOABL_Path + "/bin/hbond2noe " + src_file + " > " + fasta_name + ".hbond.tbl")
			os.system(GLOABL_Path + "/bin/hbond2ssnoe " + src_file + " > " + fasta_name + ".ssnoe.tbl")
		else:
			os.system(GLOABL_Path + "/bin/hbond2noe " + src_file + " > " + dst_dir + '/' + fasta_name + ".hbond.tbl")
			os.system(GLOABL_Path + "/bin/hbond2ssnoe " + src_file + " > " + dst_dir + '/' + fasta_name + ".ssnoe.tbl")

def generate_pred_shell(shell_file, customdir, outdir, fasta, option):
	chkdirs(shell_file)
	# every will remove the old shell file
	if os.path.exists(shell_file): 
		os.remove(shell_file)
	with open(shell_file, "a") as myfile:
		myfile.write('#!/bin/bash -l\n')
		# if os.system('uname -n') == 'lewis':
		# 	myfile.write('#SBATCH -J  %s\n'%fasta)
		# 	myfile.write('#SBATCH -o %s-%%j.out\n'%fasta)
		# 	myfile.write('#SBATCH -p Lewis,hpc4,hpc5\n')
		# 	myfile.write('#SBATCH -N 1\n')
		# 	myfile.write('#SBATCH -n 8\n')
		# 	myfile.write('#SBATCH -t 2-00:00\n')
		# 	myfile.write('#SBATCH --mem 20G\n')
		# 	myfile.write('module load cuda/cuda-9.0.176\n')
		# 	myfile.write('module load cudnn/cudnn-7.1.4-cuda-9.0.176\n')
		myfile.write('export GPUARRAY_FORCE_CUDA_DRIVER_LOAD=\"\"\n')
		myfile.write('export HDF5_USE_FILE_LOCKING=FALSE\n')
		myfile.write('\n##GLOBAL_FLAG\n')
		myfile.write('global_dir=/storage/htc/bdm/tianqi/MULTICOM2/DeepHbond')
		myfile.write('\n## ENV_FLAG\n')
		myfile.write('source $global_dir/env/deephbond_virenv/bin/activate\n')
		if option == 'ALN':
			myfile.write('models_dir[0]=$global_dir/models/pretrain/deephbond_agrc_20/1.dres152_deepcov_cov_ccmpred_pearson_pssm/\n')
			myfile.write('models_dir[1]=$global_dir/models/pretrain/deephbond_agrc_20/2.dres152_deepcov_plm_pearson_pssm/\n')
			myfile.write('models_dir[2]=$global_dir/models/pretrain/deephbond_agrc_20/3.res152_deepcov_pre_freecontact/\n')
			myfile.write('models_dir[3]=$global_dir/models/pretrain/deephbond_agrc_20/4.res152_deepcov_other/\n')
			myfile.write('output_dir=%s/aln/\n'%(customdir))
		elif option == 'MSA':
			myfile.write('models_dir[0]=$global_dir/models/pretrain/deephbond_agrc_20_msa/1.dres152_deepcov_cov_ccmpred_pearson_pssm/\n')
			myfile.write('models_dir[1]=$global_dir/models/pretrain/deephbond_agrc_20_msa/2.dres152_deepcov_plm_pearson_pssm/\n')
			myfile.write('models_dir[2]=$global_dir/models/pretrain/deephbond_agrc_20_msa/3.res152_deepcov_pre_freecontact/\n')
			myfile.write('models_dir[3]=$global_dir/models/pretrain/deephbond_agrc_20_msa/4.res152_deepcov_other/\n')
			myfile.write('output_dir=%s/msa/\n'%(customdir))
		myfile.write('fasta=%s/%s.fasta\n'%(outdir, fasta))
		myfile.write('\n## DBTOOL_FLAG\n')
		myfile.write('db_tool_dir=/storage/htc/bdm/zhiye/DNCON4_db_tools/')
		myfile.write('\nprintf \"$global_dir\"\n')
		myfile.write('#################CV_dir output_dir dataset database_path\n')
		if option == 'ALN':
			myfile.write('python $global_dir/lib/Model_predict.py $db_tool_dir $fasta ${models_dir[@]} $output_dir \'ALN\'\n') #aln
		elif option == 'MSA':
			myfile.write('python $global_dir/lib/Model_predict.py $db_tool_dir $fasta ${models_dir[@]} $output_dir \'MSA\'\n')

		
if __name__=="__main__":
	parser = argparse.ArgumentParser()
	parser.description="DeepHbond - The best hhbond contact predictor in the world."
	parser.add_argument("-f", "--fasta", help="input fasta file",type=is_file,required=True)
	parser.add_argument("-o", "--outdir", help="output folder",type=str,required=True)
	parser.add_argument("-dm", "--domain", help="e.g. domain 0:1-124 easy", required=False)

	args = parser.parse_args()
	fasta = args.fasta
	outdir = args.outdir
	dm_index_file = args.domain
	DM_FLAG = False

	chkdirs(outdir + '/')
	#copy fasta to outdir
	os.system('cp %s %s'%(fasta, outdir))
	fasta_file = fasta.split('/')[-1]
	fasta_name = fasta_file.split('.')[0]
	fasta = os.path.join(outdir, fasta_file) # is the full path of fasta

	#process if have domian info
	if dm_index_file is not None:
		if os.path.exists(dm_index_file) and os.path.getsize(dm_index_file) != 0:
			DM_FLAG = True
			dm_name_dict = cut_domain_fasta(fasta_name, outdir, dm_index_file)
			if dm_name_dict == False:
				print("No domain been detected!")
				DM_FLAG = False
			elif len(dm_name_dict) < 1:
				print("Cut domain failed, please check!")

	#generate shell file
	full_length_dir = outdir + '/full_length/'
	chkdirs(full_length_dir)
	aln_shell_file =  outdir + '/shell/%s_aln.sh'%fasta_name
	msa_shell_file =  outdir + '/shell/%s_msa.sh'%fasta_name
	generate_pred_shell(aln_shell_file, full_length_dir, outdir, fasta_name, 'ALN')
	generate_pred_shell(msa_shell_file, full_length_dir, outdir, fasta_name, 'MSA')
	os.system('chmod 777 %s'%aln_shell_file)
	os.system('chmod 777 %s'%msa_shell_file)

	if DM_FLAG:
		domain_dir_dict = {}
		count = 0
		for dm_fasta_name in dm_name_dict:
			domain_dir = outdir + '/%s/'%dm_fasta_name
			count += 1
			chkdirs(domain_dir)
			domain_dir_dict[dm_fasta_name] = domain_dir
			aln_shell_file =  outdir + '/shell/%s_aln.sh'%dm_fasta_name
			msa_shell_file =  outdir + '/shell/%s_msa.sh'%dm_fasta_name
			generate_pred_shell(aln_shell_file, domain_dir, outdir, dm_fasta_name, 'ALN')
			generate_pred_shell(msa_shell_file, domain_dir, outdir, dm_fasta_name, 'MSA')
			os.system('chmod 777 %s'%aln_shell_file)
			os.system('chmod 777 %s'%msa_shell_file)

	print('Subprocess the deepaln and deepmsa pipline!')
	procs = []
	for file in glob.glob(outdir + '/shell/%s*.sh'%fasta_name):
		proc = Process(target=run_shell_file, args=(file,))
		procs.append(proc)
		proc.start()

	for proc in procs:
		proc.join()

	# ensemble
	ensem_dir = ensemble_aln_msa(fasta_name, full_length_dir)
	if DM_FLAG:
		domain_ensem_dir_dict = {}
		for dm_fasta_name in dm_name_dict:
			domain_dir = outdir + '/%s/'%dm_fasta_name
			dm_ensem_dir = ensemble_aln_msa(dm_fasta_name, domain_dir)
			domain_ensem_dir_dict[dm_fasta_name] = dm_ensem_dir

	# combine with domain
	if DM_FLAG:
		ensem_dir = combine_dm_fl(full_length_dir, domain_dir_dict, dm_name_dict)
	# generate dist rr 

	hhbond_file = generate_hhbond_for_dfold(fasta_name, outdir, ensem_dir)
	hhbond_file_top = get_topnL_hhbonds(hhbond_file)
	hhbond_file_filter = filter_hhbond(hhbond_file_top)
	generate_hhbond_constrain(hhbond_file_filter, fasta_name, outdir)
	if DM_FLAG:
		for dm_fasta_name in dm_name_dict:
			tmp_dm_dir = domain_ensem_dir_dict[dm_fasta_name]
			dm_hhbond_file = generate_hhbond_for_dfold(dm_fasta_name, outdir, tmp_dm_dir)
			dm_hhbond_file_top = get_topnL_hhbonds(dm_hhbond_file)
			dm_hhbond_file_filter = filter_hhbond(dm_hhbond_file_top)
			generate_hhbond_constrain(dm_hhbond_file_filter, dm_fasta_name, outdir)
	# copy ss file /exports/store2/casp14/tools/deephbond/predictors/results/T0949/full_length/aln/psipred
	src_ss_file = full_length_dir + '/aln/psipred/' + fasta_name + '.ss2'
	dst_ss_file = outdir + '/' + fasta_name + '.ss2'
	shutil.copy(src_ss_file, dst_ss_file)
	if DM_FLAG:
		for dm_fasta_name in dm_name_dict:
			tmp_dm_dir = domain_dir_dict[dm_fasta_name]
			src_ss_file = tmp_dm_dir + '/aln/psipred/' + dm_fasta_name + '.ss2'
			dst_ss_file = outdir + '/' + dm_fasta_name + '.ss2'
			shutil.copy(src_ss_file, dst_ss_file)
	print('Final hhbonds constrain folder: %s'%(outdir))	