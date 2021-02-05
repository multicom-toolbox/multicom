import sys,os,glob,re

docstring='''
MULTICOM2 configuration script

usage: python configure.py
'''

def makedir_if_not_exists(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)
    directory = os.path.abspath(directory)
    return directory

def die(msg):
  print(msg)
  sys.exit(1)

def configure_file(option_list,prefix):
    if not os.path.exists(option_list):
        die("\nOption file %s not exists."%option_list)

    file_indx=0;
    for line in open(option_list):
        line = line.rstrip()
        if line.startswith(prefix):
            option_default = os.path.join(install_dir,line+'.default')
            option_new = os.path.join(install_dir,line)

            f = open(option_new,"w")
            file_indx = file_indx + 1
            print("%d: Configuring %s" % (file_indx,option_new))
            if not os.path.exists(option_default):
                die("\nOption file %s not exists."% option_default)
            for line in open(option_default):
                line = line.rstrip()
                if "SOFTWARE_PATH" in line:
                    line = re.sub("SOFTWARE_PATH",install_dir,line)
                f.write(line+"\n")
            f.close()
            os.system("chmod -R 775 "+option_new)

def check_file(option_list,prefix):
    if not os.path.exists(option_list):
        die("\nOption file %s not exists."%option_list)

    file_indx=0;
    for line in open(option_list):
        line = line.rstrip()
        if line.startswith(prefix):
            folder_path = os.path.join(install_dir,line)
            if not os.path.exists(folder_path):
                print("The tool %s is not found. Please check the %s package or contact us"%(folder_path, prefix))

if __name__ == '__main__':
    argv=[]
    for arg in sys.argv[1:]:
        if arg.startswith("-h"):
            print(docstring)

    install_dir = os.path.dirname(os.path.realpath(__file__))
    print("Intall MULTICOM2 to "+ install_dir +"....")

    database_dir = os.path.join(install_dir, "databases")
    tools_dir = os.path.join(install_dir, "tools")
    bin_dir = os.path.join(install_dir, "bin")
    makedir_if_not_exists(database_dir)
    makedir_if_not_exists(tools_dir)
    makedir_if_not_exists(bin_dir)

    print("#########  (1) Configuring option files")
    option_list = os.path.join(install_dir, "installation/MULTICOM_configure_files/multicom_option_list")
    configure_file(option_list,'src')
    configure_file(option_list,'tools')
    print("#########  Configuring option files, done\n")

    print("#########  (2)  Configuring MULTICOM2 programs")
    option_list = os.path.join(install_dir, "installation/MULTICOM_configure_files/multicom_script_list")
    configure_file(option_list,'installation')
    os.system("cp "+install_dir+"/installation/MULTICOM_programs/*.sh "+bin_dir)
    os.system("cp "+install_dir+"/src/run_multicom2.sh "+bin_dir)
    print("#########  Configuring MULTICOM2 programs, done\n")

    print("#########  (3)  Checking database files")
    option_list = os.path.join(install_dir, "installation/MULTICOM_configure_files/multicom_databases_packages.list")
    check_file(option_list,'databases');
    print("#########  Checking database files, done\n\n\n")

    print("#########  (4) Checking tool files")
    option_list = os.path.join(install_dir,"installation/MULTICOM_configure_files/multicom_tools_packages.list")
    check_file(option_list,'tools');
    print("#########  Checking tool files, done\n\n\n")
    