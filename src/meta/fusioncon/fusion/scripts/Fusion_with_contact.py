#!usr/bin/env python
############################################################################
#
#	 FUSION : A Probabilistic Model of Protein Conformational Space
#
#	 Copyright (C) 2014 -2024	Debswapna Bhattacharya and Jianlin Cheng
#
#	 FUSION is free software: you can redistribute it and/or modify
#	 it under the terms of the GNU General Public License as published by
#	 the Free Software Foundation, either version 3 of the License, or
#	 (at your option) any later version.
#
#	 FUSION is distributed in the hope that it will be useful,
#	 but WITHOUT ANY WARRANTY; without even the implied warranty of
#	 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
#	 GNU General Public License for more details.
#
#	 You should have received a copy of the GNU General Public License
#	 along with FUSION.	 If not, see <http://www.gnu.org/licenses/>.
#
############################################################################
#
#	 Method to perform hybrid remodeling (TS)
#
############################################################################


from fusion_lib import *

print ''
print '  ############################################################################'
print '  #                                                                          #'
print '  #      FUSION : A Probabilistic Model of Protein Conformational Space      #'
print '  #                                                                          #'
print '  #   Copyright (C) 2014 - 2024   Debswapna Bhattacharya and Jianlin Cheng   #'
print '  #                                                                          #'
print '  #   FUSION is free software: you can redistribute it and/or modify         #'
print '  #   it under the terms of the GNU General Public License as published by   #'
print '  #   the Free Software Foundation, either version 3 of the License, or      #'
print '  #   (at your option) any later version.                                    #'
print '  #                                                                          #'
print '  #   FUSION is distributed in the hope that it will be useful,              #'
print '  #   but WITHOUT ANY WARRANTY; without even the implied warranty of         #'
print '  #   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           #'
print '  #   GNU General Public License for more details.                           #'
print '  #                                                                          #'
print '  #   You should have received a copy of the GNU General Public License      #'
print '  #   along with FUSION. If not, see <http://www.gnu.org/licenses/>.         #'
print '  #                                                                          #'
print '  ############################################################################'
print '  #                                                                          #'
print '  #   Method to perform hybrid remodeling (TS)                               #'
print '  #                                                                          #'
print '  ############################################################################'
print ''

parser = optparse.OptionParser()
parser.add_option('--target', dest='target',
	default = 'test',    # default target name is test
	help = 'name of target protein')
parser.add_option('--pdb', dest = 'pdb',
	default = '',    # default empty!
	help = 'PDB file containing random structure for the target protein')
parser.add_option('--fasta', dest = 'fasta',
	default = '',    # default empty!
	help = 'FASTA file containing the protein to sequence to fold')
parser.add_option( '--sequence', dest = 'sequence',
	default = '',    # default empty!
	help = 'protein sequence to fold')
parser.add_option( '--email', dest = 'email',
	default = '',    # default empty!
	help = 'reply email address to send predictions')
parser.add_option( '--dir', dest = 'dir',
	default = '',    # default empty!
	help = 'root directory for results')
parser.add_option( '--timeout', dest = 'timeout',
	default = '60.0',    # default 60.0
	help = 'maximum sampling time in hours')
parser.add_option( '--alignment', dest = 'alignment',
	default = '',    # default empty!
	help = 'alignement file for the target')
parser.add_option( '--constraint', dest = 'constraint',
	default = '',    # default empty!
	help = 'custom constraint for the target')
parser.add_option('--native', dest = 'native',
	default = '',    # default empty!
	help = 'native PDB file used for benchmarking')
parser.add_option( '--cpu', dest = 'cpu',
	default = '10',    # default 10
	help = 'number of parallel cpu to be used')
parser.add_option( '--decoy', dest = 'decoy',
	default = '10000',    # default 10000
	help = 'number of decoy structure to sample')
parser.add_option( '--model', dest = 'model',
	default = '5',    # default 5
	help = 'number of models to generate')
parser.add_option( '--increase_cycle', dest = 'increase_cycle',
	default = '1',    # default 1
	help = 'increase default cycles by factor')
parser.add_option( '--author', dest = 'author',
	default = 'FUSION',    # default FUSION
	help = 'the name of the server')

(options,args) = parser.parse_args()

target = options.target
# the user may input a PDB file, fasta file, or sequence directly
pose = Pose()
# Sequence file option
if options.fasta:	
	f = open(options.fasta, 'r')	
	sequence = f.readlines()	
	f.close()	
	# removing the trailing "\n" and any header lines
	sequence = [line.strip() for line in sequence if not '>' in line]
	sequence = ''.join( sequence )
	make_pose_from_sequence(pose, sequence, 'fa_standard')
elif options.sequence:
	sequence = options.sequence
	make_pose_from_sequence(pose, sequence, 'fa_standard')
elif options.pdb:
	pdb = options.pdb
	pose_from_pdb(pose, pdb)
else:
	print 'Error ! target protein not defined. Exiting application...'
	sys.exit(1)

email = options.email

dir = options.dir
if dir:
	curr_dir = dir
else:
	curr_dir = os.getcwd()

timeout = float(options.timeout)

alignment = options.alignment
constraint = options.constraint

native = options.native
if native:
	native_pose = Pose()
	pose_from_pdb(native_pose, native)

cpu = int(options.cpu)
decoy = int(options.decoy)
model = int(options.model)
decoy_per_cpu = decoy/cpu
increase_cycle = int(options.increase_cycle)
author = options.author


work_dir = curr_dir + '/' + target
if not os.path.exists(work_dir):
	os.makedirs(work_dir)

os.chdir(work_dir)

remodel_dir = work_dir + '/remodel'
if not os.path.exists(remodel_dir):
	os.makedirs(remodel_dir)

remodel_file = target + '_remodel.txt'
remodel_constraint_file = target + '_remodel.cst'

remodel = AmbiguousAlignmentConstraintMover(pose)
remodel.set_alignment_file(alignment)
remodel.dump_remodel_file(os.path.join(remodel_dir,remodel_file))
parent = remodel.dump_remodel_constraints(os.path.join(remodel_dir,remodel_constraint_file))

os.chdir(work_dir)
remodeling = FusionRemodeling()
remodeling.set_target(target)
remodeling.set_reply_email(email)
remodeling.set_simulation_timeout(timeout)
if constraint:
	remodeling.set_custom_constraint(constraint)
remodeling.set_remodel_file(os.path.join(remodel_dir,remodel_file))
remodeling.set_remodel_constraint_file(os.path.join(remodel_dir,remodel_constraint_file))
remodeling.set_cpu(cpu)
remodeling.set_decoy_per_cpu(decoy_per_cpu)
remodeling.set_num_model(model)
remodeling.set_cycle_factor(increase_cycle)
if native:
	remodeling.set_native(native_pose)
remodeling.set_author(author)
remodeling.set_parent(parent)
remodeling.apply(pose)
os.chdir(curr_dir)
retcode = os.system('tar -czvf ' + target + '.tar.gz ' + target + '> /dev/null 2>&1')
if retcode == 0:
	os.system('rm -rf ' + target + '> /dev/null 2>&1')