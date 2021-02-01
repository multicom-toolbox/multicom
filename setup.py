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

def direct_download(tool, address, tools_dir):  ####Tools don't need to be configured after downloading and configuring
    os.chdir(tools_dir)
    if not os.path.exists(tools_dir+"/"+tool):
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
    os.system("ln -s pdb70_a3m.ffdata pdb70_a3m_db")
    os.system("ln -s pdb70_hhm.ffdata pdb70_hhm_db")

    #### Download UniRef30_2020_02
    print("Download UniRef30_2020_02\n");
    direct_download("direct_download","http://gwdu111.gwdg.de/~compbiol/uniclust/2020_03/UniRef30_2020_03_hhsuite.tar.gz",UniRef30_2020_02)
    os.chdir("UniRef30_2020_02")
    os.system("ln -s UniRef30_2020_02_a3m.ffdata UniRef30_2020_02_a3m_db")
    os.system("ln -s UniRef30_2020_02_hhm.ffdata UniRef30_2020_02_hhm_db")

    ### (2) Download basic tools
    os.chdir(tools_dir)
    tools_lst = ["blast-2.2.17", "clustalw1.83", "dfold2", "hhsuite-2.0.8-linux-x86_64" ,"hmmer3", "meta", "pairwiseQA", "psipred-2.61", "scwrl4", "tm_score", "casp_tools", "deepmsa", "disorder_new", "hhblits", "hhsuite-3.2.0","maxcluster","prosys","pspro2","tm_align2","disrank"]
    for tool in tools_lst:
        if os.path.exists(log_dir+"/"+tool+".done"):
            print(log_dir+"/"+tool+" installed....skip")
        else:
            os.system("touch "+log_dir+"/"+tool+".running")
            tool = tool+".tar.gz"
            address = "http://daisy.rnet.missouri.edu/multicom_db_tools/multicom2/tools/"+tool+".tar.gz"
            direct_download(tool, address, tools_dir)
            os.system("chmod -R 777 "+tools_dir+"/"+tool)
            os.system("mv "+log_dir+"/"+tool+".running "+log_dir+"/"+tool+".done")
            print(log_dir+"/"+tool+" installed")

#### Download modeller-9.16
    tool = tools_dir+"/modeller-9.16"
    if os.path.exists(log_dir+"/"+tool+".done"):
        print(log_dir+"/"+tool+" installed....skip")
    else:
        os.system("touch "+log_dir+"/"+tool+".running")
        tool = tool+".tar.gz"
        address = "wget http://daisy.rnet.missouri.edu/multicom_db_tools/multicom2/tools/"+tool+".tar.gz"
        direct_download(tool, address, tools_dir)
        tool = re.sub("\.tar.gz","",tool)
        os.chdir(tools_dir+"/"+tool+"/modlib/modeller")
        print(tools_dir+"/"+tool)
        config_file = open("config.py","w")
        config_file.write("install_dir = r\'"+install_dir+"/tools/modeller-9.16/\'\n")
        config_file.write("license = \'MODELIRANJE\'")
        config.close()
        os.system("mv "+log_dir+"/"+tool+".running "+log_dir+"/"+tool+".done")
        print(install_dir+"/"+tool+" installed")


