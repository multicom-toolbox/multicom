######################hhsuite_local2model.py###########################
##input: hhsuite_dir template_raw.pdb template_local.pdb##
import time,os,sys
import argparse
from subprocess import Popen, PIPE
import glob,re
from string import Template
import shutil

src_dir = os.path.dirname(os.path.abspath(__file__))
src_dict=dict(
    local2model   = os.path.join(src_dir ,"local2model.pl"),
    pir2pdb   = os.path.join(src_dir ,"pir2pdb.py"),
)

#### local2model templates ####
# $fasta   - full path of fasta file
# $fasta_id   -  T0949.fasta
# $out  - output dir
local2model_template=Template("perl "+src_dict["local2model"]+" "+src_dir+"/hhsuite_option $fasta $fasta_id $out")

#### pir2pdb templates ####
# $pir   - full path of each pir file
# $pdb_dir   -  template pdb folder
# $out  - output dir
pir2pdb_template=Template("python "+src_dict["pir2pdb"]+" -pir $pir -db $pdb_dir -out $out")

def local2model(fasta,fasta_id,outdir):
    local2model_cmd = local2model_template.substitute(
        fasta   = fasta,
        fasta_id    = fasta_id,
        out   = outdir,
    )
    #print(local2model_cmd)
    p=Popen(local2model_cmd,
            shell=True,stdin=PIPE, stdout=PIPE, stderr=PIPE)
    output, err = p.communicate()
    status = p.returncode
    if status == 0:
        return True
    else:
        print("Failed to generate pir files "+local2model_cmd)
        return False

def pir2pdb(pir,pdb_dir,outdir):
    pir2pdb_cmd = pir2pdb_template.substitute(
        pir   = pir,
        pdb_dir    = pdb_dir,
        out   = outdir,
    )
    #print(local2model_cmd)
    p=Popen(pir2pdb_cmd,
            shell=True,stdin=PIPE, stdout=PIPE, stderr=PIPE)
    output, err = p.communicate()
    status = p.returncode
    if status == 0:
        return True
    else:
        print("Failed to generate aligned map "+pir2pdb_cmd)
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
    #### command line argument parsing ####
    parser = argparse.ArgumentParser()
    parser.description="hhsuite_local2model.py - Generate Top 100 templates from hhsuite search result and rank by distance"
    parser.add_argument("-f", help="target fasta file",type=is_file,required=True)
    parser.add_argument("-hs", help="hhsuite dir",type=is_dir,required=True)
    parser.add_argument("-db", help="template pdb folder, all files are stored in .gz format",type=is_dir,required=True)
    parser.add_argument("-out", help="output dir",type=str,required=True)

    args = parser.parse_args()
    fasta = args.f
    hs = args.hs
    pdb_dir = args.db
    outdir = args.out
    
    #### Input fasta file's id
    fasta = os.path.abspath(fasta)
    fasta_id = os.path.basename(fasta)
    hs = os.path.abspath(hs)
    pdb_dir = os.path.abspath(pdb_dir)
    outdir = os.path.abspath(outdir)
    mkdir_if_not_exist(outdir)
    os.chdir(outdir)

    #Step 1: Copy input hhsuite dir into output dir
    print("Step 1: Copy input hhsuite dir into output dir")
    dest = os.path.join(outdir,"hhsuite_orig")
    mkdir_if_not_exist(dest)
    hs_file = os.path.join(hs,fasta_id+".ext")
    shutil.copy(hs_file, dest)
    hs_file = os.path.join(hs,fasta_id+".local")
    shutil.copy(hs_file, dest)
    hs_file = os.path.join(hs,fasta_id+".local.ext")
    shutil.copy(hs_file, dest)
    hs_file = os.path.join(hs,fasta_id+".sim")
    shutil.copy(hs_file, dest)

    #Step 2: Generate pir files for top 100 templates and aligned maps
    print("Step 2: Generate pir files for up to 100 templates")
    if local2model(fasta,fasta_id,dest):
        for file in glob.glob(dest+"/*.pir"):
            print("Step 3: Generate aligned maps for "+file)
            pir2pdb(file,pdb_dir,outdir)
