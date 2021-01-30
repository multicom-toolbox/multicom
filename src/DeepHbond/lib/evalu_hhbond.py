# -*- coding: utf-8 -*-
"""
Created on Wed Feb 13 12:23:17 2019

@author: Tianqi
"""
import sys
import subprocess
import os,glob,re
import time
from math import sqrt
import numpy as np

if len(sys.argv) != 4:
    print('####please input the right parameters####')
    print('[1]cmap_dir,[2]rr_dir,[3]list_choose("casp13" or "deepmsa" or "cameo" or "casp13_tbm" or "dncon2" or "casp12")\n')
    sys.exit(1)
# Locations of .cmap
cmap_dir = sys.argv[1]
rr_dir = sys.argv[2]
list_choose = sys.argv[3]
# ################## Download and prepare the dataset ##################

def cmap2rr(cmap_dir,rr_dir, GLOABL_Path, list_choose='casp13'):

     for filename in glob.glob(cmap_dir+'/*.txt'):
        id = os.path.basename(filename)
        id = re.sub('\.txt$', '', id)
        f = open(rr_dir+"/"+id+".raw",'w')
        cmap = np.loadtxt(filename,dtype='float32')
        L = cmap.shape[0]
        for i in range(0,L):
            for j in range(0,L): #for confold2, j = i+5
                # f.write(str(i+1)+" "+str(j+1)+" 0 3.5 "+str(cmap[i][j])+"\n")
                f.write(str(i+1)+" "+str(j+1)+" 0 3.5 "+'%.4f'%(cmap[i][j])+"\n")
        f.close()
        if list_choose == 'casp13_43':
            os.system('egrep -v \"^>\" '+'/mnt/data/zhiye/Python/DNCON4/data/CASP13/fasta/'+id+'.fasta'+'  > '+id+'.hhbonds')
        # if list_choose == 'deepmsa':
        #     os.system('egrep -v \"^>\" '+'/mnt/data/zhiye/Python/DNCON4_db_tools/features/DEEPMSA/fasta/'+id+'.fasta'+'  > '+id+'.hhbonds')
        # if list_choose == 'cameo':
        #     os.system('egrep -v \"^>\" '+'/mnt/data/zhiye/Python/DNCON4_db_tools/features/CAMEO/fasta/'+id+'.fasta'+'  > '+id+'.hhbonds')
        # elif list_choose == 'casp13_tbm':
        #     os.system('egrep -v \"^>\" '+GLOABL_Path+'/data/CASP13_TBM/fasta/'+id+'.fasta'+'  > '+id+'.hhbonds')
        # elif list_choose == 'casp12':
        #     os.system('egrep -v \"^>\" '+'/mnt/data/zhiye/Python/DNCON4_db_tools/features/CASP12/fasta/'+id+'.fasta'+'  > '+id+'.hhbonds')

        os.system('cat '+id+'.raw >> '+id+'.hhbonds')
        os.system('rm -f '+id+'.raw')

# ############################## Main program ################################

def main():
    GLOABL_Path = sys.path[0].split('DeepHBond')[0]+'DeepHBond/'
    print("Find gloabl path :", GLOABL_Path)
    print("It may take 1 or 2 minutes.....")
    if not os.path.exists(rr_dir):
        os.makedirs(rr_dir)
    else:
        os.system('rm -rf '+ rr_dir + '/*') 
    os.chdir(rr_dir)
    cmap2rr(cmap_dir,rr_dir, GLOABL_Path, list_choose)
    if list_choose == 'casp13_37':
        list_to_call = GLOABL_Path + "/data/CASP13/fm_tbm_37.lst"
        pdb_dir = GLOABL_Path + "/data/CASP13/pdb/"
    elif list_choose == 'casp13_43':
        list_to_call = "/mnt/data/zhiye/Python/DNCON4/data/CASP13/fm_tbm_43.lst"
        pdb_dir = "/mnt/data/zhiye/Python/DNCON4/data/CASP13/pdb43/"
    elif list_choose == 'deepmsa':
        list_to_call = "/mnt/data/zhiye/Python/DNCON4_db_tools/features/DEEPMSA//test.lst"
        pdb_dir = "/mnt/data/zhiye/Python/DNCON4_db_tools/features/DEEPMSA/pdb/"
    elif list_choose == 'cameo':
        list_to_call = "/mnt/data/zhiye/Python/DNCON4_db_tools/features/CAMEO/test.lst"
        pdb_dir = "/mnt/data/zhiye/Python/DNCON4_db_tools/features/CAMEO/pdb/"
    elif list_choose == 'casp12':
        list_to_call = "/mnt/data/zhiye/Python/DNCON4_db_tools/features/CASP12/fm_tbm.lst"
        pdb_dir = "/mnt/data/zhiye/Python/DNCON4_db_tools/features/CASP12/pdb/"
    elif list_choose == 'dncon2': # this will got error
        list_to_call = "/storage/htc/bdm/DNCON4/test/dncon2_195.lst"
        pdb_dir = GLOABL_Path + "/data/badri_training_benchmark/pdb/"
    elif list_choose == 'casp13_tbm':
        list_to_call = GLOABL_Path + "/data/CASP13_TBM/tbl.lst"
        pdb_dir = GLOABL_Path + "/data/CASP13_TBM/pdb/"

    print(list_to_call, pdb_dir, rr_dir)
    for line in open(list_to_call,'r'):
        line = line.rstrip()
        arr = line.split('-')
        print(arr[0]+" evaluated")
        # print("perl "+GLOABL_Path+"/test/scripts/coneva-lite.pl -rr "+rr_dir+"/"+arr[0]+".rr -pdb "+ pdb_dir+ line+".pdb >> "+rr_dir+"/rr.txt")
        subprocess.call("perl "+GLOABL_Path+"/lib/boneva.pl -rr "+rr_dir+"/"+arr[0]+".hhbonds -pdb "+ pdb_dir+ line+".pdb -d 3.5 -atom hhbonds -smin 3 >> "+rr_dir+"/rr.txt",shell=True)

    final_acc_reprot = "%s/coneva.result" % (cmap_dir) 
    with open(final_acc_reprot, "a") as myfile:
        myfile.write(time.strftime('\n\n%Y-%m-%d %H:%M:%S',time.localtime(time.time())))        
    title_line = "\nPRECISION                     Top-5     Top-L/10  Top-L/5   Top-L/2   Top-L     Top-2L    "
    with open(final_acc_reprot, "a") as myfile:
        myfile.write(title_line)
        myfile.write('\n')
    print(title_line)   
    top5_acc = topL10_acc = topL5_acc = topL2_acc = topL_acc = top2L_acc = 0 
    count = 0
    for line in open(rr_dir+"/rr.txt",'r'):
        line = line.rstrip()
        if(".pdb (precision)" in line):
            arr = line.split()
            print(arr[0])  
            with open(final_acc_reprot, "a") as myfile:
                myfile.write(' ')
                myfile.write(arr[0])
                myfile.write('\n')
        if(".hhbonds (precision)" in line):
            count += 1
            print(line, end=' ')
            with open(final_acc_reprot, "a") as myfile:
                myfile.write(line)
            _array = line.split(' ')
            array = [x for x in _array if x !='']
            top5_acc   += float(array[2])
            topL10_acc += float(array[3])
            topL5_acc  += float(array[4])
            topL2_acc  += float(array[5])
            topL_acc   += float(array[6])
            top2L_acc  += float(array[7])
    top5_acc   /= count
    topL10_acc /= count
    topL5_acc  /= count
    topL2_acc  /= count
    topL_acc   /= count
    top2L_acc  /= count
    final_line = "AVERAGE                       %.2f     %.2f     %.2f     %.2f     %.2f     %.2f    \n"%(top5_acc, topL10_acc, topL5_acc, topL2_acc, topL_acc, top2L_acc)
    print(final_line)
    with open(final_acc_reprot, "a") as myfile:
        myfile.write(final_line)
    os.system('rm -f rr.txt') 

if __name__=="__main__":
    main()
