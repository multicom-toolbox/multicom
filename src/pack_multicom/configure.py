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

def configure_file(option_list):
    if not os.path.exists(option_list):
        die("\nOption file %s not exists."%option_list)

    file_indx=0;
    for line in open(option_list):
        line = line.rstrip()
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


if __name__ == '__main__':
    argv=[]
    for arg in sys.argv[1:]:
        if arg.startswith("-h"):
            print(docstring)

    install_dir = os.path.dirname(os.path.realpath(__file__))
    print("Intall MULTICOM2 package scripts to "+ install_dir +"....")

    print("#########Configuring option files")
    option_list = os.path.join(install_dir, "package_script_list")
    configure_file(option_list)
    
