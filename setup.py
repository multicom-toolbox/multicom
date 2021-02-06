#!/usr/bin/env python
# -*- coding: utf-8 -*-

docstring='''
MULTICOM2-setup for database and tools

usage: python setup.py
'''

import sys
import os
import re
import glob
import subprocess

def makedir_if_not_exists(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)
    directory = os.path.abspath(directory)
    return directory

def rm_if_exists(directory):
    if os.path.exists(directory):
        directory = os.path.abspath(directory)
        if os.path.isdir(directory):
            os.system("rm -r "+directory)
        else:
            os.system("rm "+directory)

def direct_download(tool, address, tools_dir):  ####Tools don't need to be configured after downloading and configuring
    os.chdir(tools_dir)
    if not os.path.exists(tools_dir+"/"+tool):
        rm_if_exists(tools_dir+"/"+tool)
        os.system("wget "+address)
        print("Decompressing "+tools_dir+"/"+tool)
        os.system("tar -zxf "+tool+".tar.gz && rm "+tool+".tar.gz")
        os.system("chmod -R 755 "+tools_dir+"/"+tool)
        print("Downloading "+tools_dir+"/"+tool+"....Done")
    else:
        print(tool+" has been installed "+tools_dir+"/"+tool+"....Skip....")


if __name__ == '__main__':
    argv=[]
    for arg in sys.argv[1:]:
        if arg.startswith("-h"):
            print(docstring)

    # Set directory of multicom databases and tools
    install_dir = os.path.dirname(os.path.realpath(__file__))
    database_dir = os.path.join(install_dir, "databases")
    tools_dir = os.path.join(install_dir, "tools")
    bin_dir = os.path.join(install_dir, "bin")
    log_dir = os.path.join(install_dir, "installation/log")
    makedir_if_not_exists(database_dir)
    makedir_if_not_exists(tools_dir)
    makedir_if_not_exists(bin_dir)
    makedir_if_not_exists(log_dir)

    print("MULTICOM2 database path : "+ database_dir)
    print("MULTICOM2 tool path : "+ tools_dir)

    ### (1) Download databases
    os.chdir(database_dir)

    #### Download db_lst
    db_lst = ["HHsuite_PDB70","RCSB_PDB","uniref","update_db_deephybrid","update_db_hhsuite","update_db_pdb70"]
    for db in db_lst:
        print("Download "+db)
        direct_download(db,"http://daisy.rnet.missouri.edu/multicom_db_tools/multicom2/databases/"+db+".tar.gz",database_dir)

    #### Download hhsuite_dbs
    print("Download hhsuite_dbs\n");
    direct_download("hhsuite_dbs","http://daisy.rnet.missouri.edu/multicom_db_tools/multicom2/databases/hhsuite_dbs.tar.gz",database_dir)
    os.chdir("hhsuite_dbs")
    if os.path.exists("pdb70_a3m_db"):
        os.system("unlink pdb70_a3m_db")
    if os.path.exists("pdb70_hhm_db"):
        os.system("unlink pdb70_hhm_db")
    os.system("ln -s pdb70_a3m.ffdata pdb70_a3m_db")
    os.system("ln -s pdb70_hhm.ffdata pdb70_hhm_db")

    #### Download UniRef30_2020_02
    print("Download UniRef30_2020_02\n")
    #direct_download("UniRef30_2020_02","http://gwdu111.gwdg.de/~compbiol/uniclust/2020_02/UniRef30_2020_02_hhsuite.tar.gz",database_dir)
    direct_download("UniRef30_2020_02","http://daisy.rnet.missouri.edu/multicom_db_tools/multicom2/databases/UniRef30_2020_02.tar.gz",database_dir)
    os.chdir("UniRef30_2020_02")
    if os.path.exists("UniRef30_2020_02_a3m_db"):
        os.system("unlink UniRef30_2020_02_a3m_db")
    if os.path.exists("UniRef30_2020_02_hhm_db"):
        os.system("unlink UniRef30_2020_02_hhm_db")
    os.system("ln -s UniRef30_2020_02_a3m.ffdata UniRef30_2020_02_a3m_db")
    os.system("ln -s UniRef30_2020_02_hhm.ffdata UniRef30_2020_02_hhm_db")
    
    #### Download myg_uniref100_01_2020
    print("Download myg_uniref100_01_2020\n");
    direct_download("myg_uniref100_01_2020","http://sysbio.rnet.missouri.edu/dncon4_db_tools/databases/myg_uniref100_01_2020.tar.gz",database_dir)

    ### (2) Download basic tools
    os.chdir(tools_dir)
    tools_lst = ["blast-2.2.17", "clustalw1.83", "dfold2", "hhsuite-2.0.8-linux-x86_64" ,"hmmer3", "pairwiseQA", "psipred-2.61", "scwrl4", "tm_score", "casp_tools", "deepmsa", "disorder_new", "hhblits", "hhsuite-3.2.0","maxcluster","prosys","pspro2","tm_align2","distrank","trRosetta","SBROD"]
    for tool in tools_lst:
        if os.path.exists(log_dir+"/"+tool+".done"):
            print(log_dir+"/"+tool+" installed....skip")
        else:
            os.system("touch "+log_dir+"/"+tool+".running")
            address = "http://daisy.rnet.missouri.edu/multicom_db_tools/multicom2/tools/"+tool+".tar.gz"
            direct_download(tool, address, tools_dir)
            os.system("chmod -R 777 "+tools_dir+"/"+tool)
            os.system("mv "+log_dir+"/"+tool+".running "+log_dir+"/"+tool+".done")
            print(log_dir+"/"+tool+" installed")

    #### Download trRosetta
    if os.path.exists(log_dir+"/trRosetta_dist.done"):
        print(log_dir+"/trRosetta_dist installed....skip")
    else:
        os.system("touch "+log_dir+"/trRosetta_dist.running")
        os.chdir(tools_dir+"/trRosetta")
        tool = "trRosetta"
        os.system("git clone https://github.com/gjoni/trRosetta")
        os.system("mv trRosetta/network ./")
        os.system("rm -rf trRosetta")
        os.system("wget https://files.ipd.uw.edu/pub/trRosetta/model2019_07.tar.bz2")
        os.system("tar xf model2019_07.tar.bz2")
        os.system("rm model2019_07.tar.bz2")
        os.system("mv "+log_dir+"/trRosetta_dist.running "+log_dir+"/trRosetta_dist.done")
        print(log_dir+"/trRosetta_dist installed")

    #### Download DeepMSA
    if os.path.exists(log_dir+"/DeepMSA.done"):
        print(log_dir+"/DeepMSA installed....skip")
    else:
        os.system("touch "+log_dir+"/DeepMSA.running")
        tool = "deepmsa"
        address = "http://sysbio.rnet.missouri.edu/dncon4_db_tools/tools/deepmsa.tar.gz"
        direct_download(tool, address, tools_dir+"/deepmsa")
        os.system("mv "+log_dir+"/DeepMSA.running "+log_dir+"/DeepMSA.done")
        print(log_dir+"/DeepMSA installed")

    #### Download deepdist
    if os.path.exists(log_dir+"/deepdist.done"):
        print(log_dir+"/deepdist installed....skip")
    else:
        os.system("touch "+log_dir+"/deepdist.running")
        tool = "deepdist"
        os.system("git clone https://github.com/multicom-toolbox/deepdist")
        os.system("mv "+log_dir+"/deepdist.running "+log_dir+"/deepdist.done")
        print(log_dir+"/deepdist installed")

    #### Download modeller-9.16
    tool = "modeller-9.16"
    if os.path.exists(log_dir+"/"+tool+".done"):
        print(log_dir+"/"+tool+" installed....skip")
    else:
        os.system("touch "+log_dir+"/"+tool+".running")
        address = "http://daisy.rnet.missouri.edu/multicom_db_tools/multicom2/tools/"+tool+".tar.gz"
        direct_download(tool, address, tools_dir)
        os.chdir(tools_dir+"/"+tool+"/modlib/modeller")
        print(tools_dir+"/"+tool)
        config_file = open("config.py","w")
        config_file.write("install_dir = r\'"+install_dir+"/tools/modeller-9.16/\'\n")
        config_file.write("license = \'MODELIRANJE\'")
        config_file.close()
        os.system("mv "+log_dir+"/"+tool+".running "+log_dir+"/"+tool+".done")
        print(install_dir+"/"+tool+" installed")

    #### Create distrank virtual environment
    tool = "distrank"
    if (os.path.exists(log_dir+"/disrank.done")):
        if not os.path.exists(log_dir+"/distrank.done"):
            os.system("touch "+log_dir+"/distrank.running")
            print("\n"+tools_dir+"/"+tool+" installed....Setting environment...python3.6 required....\n")
            os.chdir(tools_dir+"/"+tool+"/installation")
            makedir_if_not_exists("env")
            os.system("sh set_env.sh")
            os.system("mv "+log_dir+"/distrank.running "+log_dir+"/distrank.done")
        else:
            print(tools_dir+"/"+tool+" virtual env has been created...")
    else:
        print(tools_dir+"/"+tool+" failed to install...Please check...")

    #### Create trRosetta virtual environment
    tool = "trRosetta"
    if (os.path.exists(log_dir+"/trRosetta_dist.done")):
            if not os.path.exists(log_dir+"/trRosetta_vir.done"):
                os.system("touch "+log_dir+"/trRosetta_vir.running")
                print("\n"+tools_dir+"/"+tool+" installed....Setting environment...python3.6 required....\n")
                os.chdir(tools_dir+"/"+tool+"/installation")
                makedir_if_not_exists("env")
                os.system("sh set_env.sh")
                os.system("mv "+log_dir+"/trRosetta_vir.running "+log_dir+"/trRosetta_vir.done")
            else:
                print(tools_dir+"/"+tool+" virtual env has been created...")
    else:
        print(tools_dir+"/"+tool+" failed to install...Please check...")

    #### Create trRosetta virtual environment
    tool = "deepdist"
    if (os.path.exists(log_dir+"/deepdist.done")):
            if not os.path.exists(log_dir+"/deepdist_vir.done"):
                os.system("touch "+log_dir+"/deepdist_vir.running")
                print("\n"+tools_dir+"/"+tool+" installed....Setting environment...python3.6 required....\n")
                os.chdir(tools_dir+"/"+tool)
                os.system("python setup_v2.py")
                os.system("python configure.py")
                makedir_if_not_exists("env")
                os.system("sh installation/set_env.sh")
                os.system("mv "+log_dir+"/deepdist_vir.running "+log_dir+"/deepdist_vir.done")
            else:
                print(tools_dir+"/"+tool+" virtual env has been created...")
    else:
        print(tools_dir+"/"+tool+" failed to install...Please check...")

    print("\nConfiguration....Done")
