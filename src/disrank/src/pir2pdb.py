######################pir2pdb.py###########################
##input: template.pir template_raw.pdb template_local.pdb##
import time,os,sys
import argparse
from subprocess import Popen, PIPE
import glob,re
from string import Template

src_dir = os.path.dirname(os.path.abspath(__file__))
src_dict=dict(
    pdb2dist   = os.path.join(src_dir ,"pdb2dist.pl"),
    dist2map   = os.path.join(src_dir ,"generate-Y-realDistance.pl"),
)


#### pdb2dist templates ####
# $pdb   - template pdb file
# $dist   - distance file
pdb2dist_template=Template("perl "+src_dict["pdb2dist"]+" $pdb CB 0 > $dist")

#### dist2map templates ####
# $dist   - distance file
# $l    - map dimension
# $distmap    - real distance map
dist2map_template=Template("perl "+src_dict["dist2map"]+" $dist $l > $distmap")


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

def read_pir(count,lines):
    for i in range(count):
        line = lines[i].rstrip()
        if line.startswith("C;cover size:") and lines[i+1].startswith(">"):
            line = lines[i+1].rstrip()
            arr = line.split(";")
            temp_id_pir = arr[1]
            #if temp_id != temp_id_pir:
                #sys.exit("Template pdb "+temp_id+" provided doesn't match with local alignment "+temp_id_pir)
            line = lines[i+2].rstrip()
            arr = line.split(":")
            tstart = int(arr[2].strip())
            tend = int(arr[4].strip())
            line = lines[i+3].strip()
            tseq = re.sub("\*","",line)
            break
    for i in range(count):
        line = lines[i].rstrip()
        if line.startswith("C;query_length:") and lines[i+1].startswith(">"):
            arr = line.split()
            qlen = int(re.sub("C;query_length:","",arr[0]))
            qseq = lines[i+3].rstrip()
            qseq = re.sub("\*","",qseq)
            qlen_pir = len(qseq)-qseq.count('-')
            if qlen != qlen_pir:
                sys.exit("Target length "+str(qlen)+" doesn't match with query length in local alignment file "+str(qlen_pir))
    return temp_id_pir,tstart,tend,tseq,qlen,qseq

def store_indx(tseq,tstart):
    temp_idx = dict()
    tseq = list(tseq)
    i = 1
    j = tstart
    for aa in tseq:
        if aa != '-':
            temp_idx[i] = j
            j = j+1
        i = i+1
    return temp_idx

def Intersection(lst1, lst2): 
    return set(lst1).intersection(lst2) 

def reindex_template(temp,temp_local,query_reidx):
    f = open(temp_local,"w")
    i = 0
    for line in open(temp,"r"):
        if line.startswith("ATOM"):
            atom= line[0:6].strip()
            atom_seq=int(line[6:11].strip())
            atom_name= line[12:16].strip()
            res_name =line[17:20].strip()
            chain = line[21:22]
            res_seq= int(line[22:26].strip())
            x= float(line[30:38].strip())
            y= float(line[38:46].strip())
            z= float(line[46:54].strip())
            occ= line[54:60].strip()
            tmp= line[60:66].strip()
            ele= line[76:78].strip()
            if res_seq in query_reidx:
                line= "{:6s}{:5d} {:^4s} {:3s} {:1s}{:4d}    {:8.3f}{:8.3f}{:8.3f}{:6.2f}{:6.2f}          {:>2s}  ".format(atom,int(i+1),atom_name,res_name,chain,query_reidx[res_seq],x,y,z,float(occ),float(tmp),ele)
                f.write(line+"\n")
                i = i+1
        if line.startswith("TER") or line.startswith("END"):
            f.write(line+"\n")
            break
    f.close()


def pdb2dist(temp_local,dist):
    pdb2dist_cmd = pdb2dist_template.substitute(
        pdb   = temp_local,
        dist    = dist,
    )
    #print(pdb2dist_cmd)
    p=Popen(pdb2dist_cmd,
            shell=True,stdin=PIPE, stdout=PIPE, stderr=PIPE)
    output, err = p.communicate()
    status = p.returncode
    if status == 0:
        return True
    else:
        print("Can not extract distance file from "+temp_local)
        return False

def dist2map(dist,qlen,dist_map):
    dist2map_cmd = dist2map_template.substitute(
        dist    = dist,
        l =  qlen,
        distmap = dist_map,
    )
    #print(dist2map_cmd)
    p=Popen(dist2map_cmd,
            shell=True,stdin=PIPE, stdout=PIPE, stderr=PIPE)
    output, err = p.communicate()
    status = p.returncode
    if status == 0:
        print(dist_map+" has been generated.....Done")
    else:
        print("Can not generate distance map for "+dist+".....Failed")

if __name__=="__main__":
    #### command line argument parsing ####
    parser = argparse.ArgumentParser()
    parser.description="pir2pdb.py - Extract local structure from template based on pir file"
    parser.add_argument("-pir", help="alignment file .pir",type=is_file,required=True)
    parser.add_argument("-db", help="raw template pdb dir",type=is_dir,required=True)
    parser.add_argument("-out", help="output dir",type=str,required=True)

    args = parser.parse_args()
    pir = args.pir
    temp_dir = args.db
    outdir = args.out
    
    #### Input fasta file's id
    pir = os.path.abspath(pir)
    target =os.path.basename(pir)
    target=os.path.splitext(target)[0]
    temp_dir = os.path.abspath(temp_dir)
    outdir = os.path.abspath(outdir)
    mkdir_if_not_exist(outdir)
    os.chdir(outdir)

    #Step 1: Extract raw template index and aligned template sequence from pir file
    #Step 1: Extract target length and aligned target sequence from pir file    
    lines = open(pir).readlines()
    count = len(lines)
    if count< 5:
        sys.exit('no local alignments exist.')

    temp_id_pir,tstart,tend,tseq,qlen,qseq = read_pir(count,lines)
    temp = os.path.join(temp_dir,temp_id_pir+".atom.gz")
    os.system("cp "+temp+" "+outdir)
    temp = os.path.join(outdir,temp_id_pir+".atom.gz")
    os.system("gunzip -f "+temp)
    temp = re.sub("\.gz","",temp)
    #temp_local = os.path.join(outdir,temp_id_pir+"_"+str(tstart)+"_"+str(tend)+"_local.pdb")
    temp_local = os.path.join(outdir,temp_id_pir+"_"+target+"_local.pdb")
    
    #Step 2: Index aligned sequence
    temp_idx = store_indx(tseq,tstart)
    query_idx = store_indx(qseq,1)

    comm_idx = Intersection(temp_idx.keys(), query_idx.keys())

    query_reidx = dict()
    for idx in comm_idx:
        query_reidx[temp_idx[idx]] = query_idx[idx]

    #Step 3: Extract aligned part from template structure and reindex
    reindex_template(temp,temp_local,query_reidx)

    # #Step 4: Generate distance map for aligned local template structure
    # dist = os.path.join(os.path.dirname(temp),temp_id_pir+"_local.dist")
    # dist_map = os.path.join(os.path.dirname(temp),temp_id_pir+"_local.txt")
    # if pdb2dist(temp_local,dist):
        # dist2map(dist,qlen,dist_map)
