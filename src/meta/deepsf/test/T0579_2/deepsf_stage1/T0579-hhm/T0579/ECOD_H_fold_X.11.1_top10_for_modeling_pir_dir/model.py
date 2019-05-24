from modeller import *    # Load standard Modeller classes
from modeller.automodel import *    # Load the automodel class

log.verbose()  #request verbose output
env = environ()  #create a new MODELLER environment to build this model
env.io.atom_files_directory = ['.'] #directories of input atom files

a = automodel(env,
              alnfile  = 'bak_T0579_e4hh8A2.pir',      # alignment filename
              knowns = ( 'e4hh8A2'), # codes of the templates
              sequence = 'T0579')   # code of the target
a.starting_model= 1             # index of the first model
a.ending_model  = 1    # index of the last model

a.make()
