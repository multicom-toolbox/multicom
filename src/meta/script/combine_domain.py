# -*- coding: utf-8 -*-
"""
Created on Tue Feb 11 15:57:26 2020

@author: Zhiye
"""
import sys
import os,glob,re
import numpy as np

if len(sys.argv) == 5:
    fl_dir = str(sys.argv[1]) # DNCON4_RES
    dm_dir = str(sys.argv[2])  
    start_index = int(sys.argv[3]) # DNCON2, DNCON4, DEEPCOV, RESPRE
    end_index=int(sys.argv[4]) 
else:
  print('please input the right parameters')
  sys.exit(1)

def combine_dm_fl(fl_npy, dm_npy, start_index, end_index):
	domain_start = int(start_index)-1
	domain_end = int(end_index)

	L = fl_npy.shape[1]
	C = fl_npy.shape[-1]
	enmpty_map = np.zeros((1, L, L, C))
	enmpty_map[0, domain_start:domain_end, domain_start:domain_end, :] = dm_npy

	if C == 42:
		enmpty_map_bin = enmpty_map[:,:, :, 0:13].sum(axis=-1)
		full_map_bin = fl_npy[:,:, :, 0:13].sum(axis=-1)
	elif C == 25:
		enmpty_map_bin = enmpty_map[:,:, :, 0:8].sum(axis=-1)
		full_map_bin = fl_npy[:,:, :, 0:8].sum(axis=-1)
	elif C == 18:
		enmpty_map_bin = enmpty_map[:,:, :, 0:9].sum(axis=-1)
		full_map_bin = fl_npy[:,:, :, 0:9].sum(axis=-1)
	elif C == 33:
		enmpty_map_bin = enmpty_map[:,:, :, 0:10].sum(axis=-1)
		full_map_bin = fl_npy[:,:, :, 0:10].sum(axis=-1)
	elif C == 10:
		enmpty_map_bin = enmpty_map[:,:, :, 0:3].sum(axis=-1)
		full_map_bin = fl_npy[:,:, :, 0:3].sum(axis=-1)


	fl_npy[enmpty_map_bin > full_map_bin, :] = enmpty_map [enmpty_map_bin > full_map_bin, :]
	# full_map[enmpty_map > full_map] = enmpty_map [enmpty_map > full_map]
	channel_sum = np.sum(fl_npy, axis = -1)
	new_full = fl_npy / channel_sum[:,:,:, np.newaxis]
	return new_full

fl_name = [a for a in os.listdir(fl_dir + '/distrib/trRosetta/') if 'npy' in a][0]
dm_name = [a for a in os.listdir(dm_dir + '/distrib/trRosetta/') if 'npy' in a][0]

fl_file = fl_dir + '/distrib/trRosetta/' + fl_name
dm_file = dm_dir + '/distrib/trRosetta/' + dm_name
fl_npy = np.load(fl_file)
dm_npy = np.load(dm_file)
new_fl_npy = combine_dm_fl(fl_npy, dm_npy, start_index, end_index)
new_fl_file = fl_dir + '/distrib/trRosetta/' + fl_name
np.save(new_fl_file, new_fl_npy)