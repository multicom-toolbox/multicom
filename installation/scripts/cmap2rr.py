# -*- coding: utf-8 -*-
"""
Created on Wed Feb 13 12:23:17 2019

@author: Tianqi
"""
import sys
import subprocess
import os,glob,re

from math import sqrt

import numpy as np

if len(sys.argv) != 3:
    print('####please input the right parameters####')
    print('[1]cmap_file,[2]rr_file\n')
    sys.exit(1)
# Locations of .cmap
cmap_file = sys.argv[1]
rr_file = sys.argv[2]
# ################## Download and prepare the dataset ##################

def cmap2rr(cmap_file,rr_file):

    f = open(rr_file,'w')
    cmap = np.loadtxt(cmap_file,dtype='float32')
    L = cmap.shape[0]
    for i in range(0,L):
        for j in range(i+1,L):
            f.write(str(i+1)+" "+str(j+1)+" 0 8 "+str(cmap[i][j])+"\n")
    f.close()

# ############################## Main program ################################

def main():
    cmap2rr(cmap_file,rr_file)

if __name__=="__main__":
    main()
