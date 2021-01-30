# -*- coding: utf-8 -*-
import os,re
import sys
import argparse
import subprocess
from string import Template
from subprocess import Popen, PIPE

#Top num templates in rank file
num = 10 

src_dir = os.path.dirname(os.path.abspath(__file__))
src_dict=dict(
    pir2ts   = os.path.join(src_dir ,"pir2ts_energy.pl"),
)


#### pir2ts templates ####
# $modeller   - modeller path
# $db   - template dir
# $out   - output folder
# $pir   - pir file
pir2ts_template=Template("perl "+src_dict["pir2ts"]+" $modeller $db $out $pir 10")

def pir2ts(modeller,temp_dir,outdir,pir,target,pir_id):
    pir2ts_cmd = pir2ts_template.substitute(
        modeller   = modeller,
        db    = temp_dir,
        out   = outdir,
        pir   = pir,
    )
    print(pir2ts_cmd)
    p=Popen(pir2ts_cmd,
            shell=True,stdin=PIPE, stdout=PIPE, stderr=PIPE)
    output, err = p.communicate()
    status = p.returncode
    os.system("rm "+outdir+"/model.log")
    os.system("mv "+pir+" "+outdir+"/"+pir_id+".pir")
    if status == 0:
        if os.path.exists(outdir+"/"+target+".pdb"):
            os.system("mv "+outdir+"/"+target+".pdb "+outdir+"/"+pir_id+".pdb")
            print("Comparative modelling for "+pir_id+" is done.\n")
        return True
    else:
        print("Can not generate model for "+pir_id)
        return False

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

def mkdir_if_not_exist(tmpdir):
    ''' create folder if not exists '''
    if not os.path.isdir(tmpdir):
        os.makedirs(tmpdir)

if __name__=="__main__":
    parser = argparse.ArgumentParser()
    parser.description="template_model.py - Top n templates in rank file that don't exist in hhsuite original ranking and convert them to global model."
    parser.add_argument("-t", help="target id T0949",type=str,required=True)
    parser.add_argument("-r", help="distrank rank.txt",type=is_file,required=True)
    parser.add_argument("-p", help="pir dir",type=is_dir,required=True)
    parser.add_argument("-n", help="Top n templates in rank file",type=int,default=10)
    parser.add_argument("-db", help="raw template pdb dir",type=is_dir,required=True)
    parser.add_argument("-m", help="modeller dir",type=is_dir,required=True)
    parser.add_argument("-o", help="output folder", type=str, required=True)

    args = parser.parse_args()
    target = args.t
    rank = args.r
    num = args.n
    pir_dir = args.p
    temp_dir = args.db
    modeller = args.m
    outdir = args.o

    rank = os.path.abspath(rank)
    temp_dir = os.path.abspath(temp_dir)
    pir_dir = os.path.abspath(pir_dir)
    modeller = os.path.abspath(modeller)
    outdir = os.path.abspath(outdir)
    mkdir_if_not_exist(outdir)
    os.chdir(outdir)
    
    g = open(outdir+"/rank.txt","w")
    with open(rank) as f:
        head = [next(f) for x in range(num)]
        j = 1
        for line in head:
            line = line.rstrip()
            arr = line.split()
            temp = arr[0]
            info = temp.split('_')
            pir = os.path.join(pir_dir,info[1]+".pir")
            temp_id = int(re.sub("hhsuite","",info[1]))
            if temp_id > num:
                g.write(str(j)+" "+info[0]+" "+info[1]+"\n")
                print(info[1]+" is not in original hhsuite top "+str(num)+" rankings")
                print("Use Modeller to generate tertiary structures for "+info[1])
                #pir2ts(modeller,temp_dir,outdir,pir,target,info[1])
                pir2ts(modeller,temp_dir,outdir,pir,target,"disrank"+str(j))
                j = j+1
    g.close()
    if j == 1:
        print("Disrank result matches with hhsuite original ranking....")
    else:
        maindir = os.path.dirname(os.path.dirname(outdir))
        os.system("cp "+outdir+"/disrank*.pdb "+maindir)
        os.system("cp "+outdir+"/disrank*.pir "+maindir)
        os.system("mv "+outdir+"/rank.txt "+maindir+"/"+target+".rank")