
### Manually install dncon2

### install boost-1.55 
cd /home/casp14/MULTICOM_TS/multicom/tools
tar -zxvf boost_1_55_0.tar.gz
cd boost_1_55_0
./bootstrap.sh  --prefix=/home/casp14/MULTICOM_TS/multicom/tools/boost_1_55_0
./b2  (will take ~20 min)
./b2 install


#### install OpenBlas
cd /home/casp14/MULTICOM_TS/multicom/tools
git clone https://github.com/xianyi/OpenBLAS.git
cd OpenBLAS
make
make PREFIX=/home/casp14/MULTICOM_TS/multicom/tools/OpenBLAS install


export PATH=/home/casp14/MULTICOM_TS/multicom/tools/boost_1_55_0/include/:$PATH
export LD_LIBRARY_PATH=/home/casp14/MULTICOM_TS/multicom/tools/boost_1_55_0/include/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/casp14/MULTICOM_TS/multicom/tools/boost_1_55_0/lib/:$LD_LIBRARY_PATH
export BOOST_ROOT=/home/casp14/MULTICOM_TS/multicom/tools/boost_1_55_0
export BOOST_INCLUDEDIR=/home/casp14/MULTICOM_TS/multicom/tools/boost_1_55_0/include
export LD_LIBRARY_PATH=/home/casp14/MULTICOM_TS/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH
export PATH=/home/casp14/MULTICOM_TS/multicom/tools/OpenBLAS:$PATH

cd /home/casp14/MULTICOM_TS/multicom/tools/DNCON2/
tar -xvf freecontact_1.0.21.orig.tar.xz 
cd freecontact-1.0.21


autoreconf -f -i
./configure --prefix=/home/casp14/MULTICOM_TS/multicom/tools/DNCON2/freecontact-1.0.21 LDFLAGS="-L/home/casp14/MULTICOM_TS/multicom/tools/OpenBLAS/lib -L/home/casp14/MULTICOM_TS/multicom/tools/boost_1_55_0/lib" CFLAGS="-I/home/casp14/MULTICOM_TS/multicom/tools/OpenBLAS/include -I/home/casp14/MULTICOM_TS/multicom/tools/boost_1_55_0/include"  CPPFLAGS="-I/home/casp14/MULTICOM_TS/multicom/tools/OpenBLAS/include -I/home/casp14/MULTICOM_TS/multicom/tools/boost_1_55_0/include " --with-boost=/home/casp14/MULTICOM_TS/multicom/tools/boost_1_55_0/
make
make install

./freecontact-1.0.21/bin/freecontact < example/5ptpA.aln



# install python environment using python2.7
virtualenv /home/casp14/MULTICOM_TS/multicom/tools/python_virtualenv
source /home/casp14/MULTICOM_TS/multicom/tools/python_virtualenv/bin/activate

(a) Install keras,theano:
export LC_ALL=C
pip install --upgrade pip
pip install --upgrade numpy==1.12.1
pip install --upgrade keras==1.2.2

pip install --upgrade theano==0.9.0
pip install --upgrade h5py
pip install --upgrade matplotlib


### use theano instead of tensorflow since tensorflow is hard to install on some old linux server
vi ~/.keras/keras.json

'''
{
    "epsilon": 1e-07,
    "image_dim_ordering": "tf",
    "backend": "theano",
    "floatx": "float32",
    "image_data_format": "channels_last"

}
'''


#### test dncon2
cd /data/jh7x3/multicom_github/multicom/tools/DNCON2/dry-run/output/test_T0866

/data/jh7x3/multicom_github/multicom/tools/DNCON2/scripts/predict-rr-from-features.sh  feat-T0866.txt  T0866.rr.raw   T0866.feat.stage2.jie.txt



cd /data/jh7x3/multicom_github/multicom/tools/DNCON2/dry-run
sh run-3e7u.sh
###########################################



/data/jh7x3/multicom_github/multicom/tools/MSACompro_1.2.0


cd /data/jh7x3/multicom_github/multicom/installation/check

### check scratch
mkdir scratch
/data/jh7x3/multicom_github/multicom/tools/SCRATCH-1D_1.1/bin/run_SCRATCH-1D_predictors.sh /data/jh7x3/multicom_github/multicom/test/T0967.fasta  /data/jh7x3/multicom_github/multicom/installation/check/scratch/T0967


### check pspro2
mkdir pspro2
(done) /data/jh7x3/multicom_github/multicom/tools/pspro2/bin/predict_ss_sa_cm.sh /data/jh7x3/multicom_github/multicom/test/T0967.fasta  /data/jh7x3/multicom_github/multicom/installation/check/pspro2/test
(done) /data/jh7x3/multicom_github/multicom/tools/pspro2/bin/predict_ssa.sh /data/jh7x3/multicom_github/multicom/test/T0967.fasta  /data/jh7x3/multicom_github/multicom/installation/check/pspro2/test

	

### check modeller

## test multicom local
perl configure.pl /data/jh7x3/multicom_github/multicom

cd  /data/jh7x3/multicom_github/multicom/test/out/full_length/


perl /data/jh7x3/multicom_github/multicom/src/multicom_ve.pl /data/jh7x3/multicom_github/multicom/src/multicom_system_option_casp13  /data/jh7x3/multicom_github/multicom/test/T0967.fasta  /data/jh7x3/multicom_github/multicom/test/out

	/data/jh7x3/multicom_github/multicom//src/meta/script/multicom_server_ve.pl /data/jh7x3/multicom_github/multicom/src/meta/test_system/multicom_option_casp13 /data/jh7x3/multicom_github/multicom/test/T0967.fasta /data/jh7x3/multicom_github/multicom/test/out/full_length
	
		# hhsearch
		(done)/data/jh7x3/multicom_github/multicom/src/meta/hhsearch/script/tm_hhsearch_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/hhsearch/hhsearch_option_cluster /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsearch 1>out.log 2>err.log
		
		#hhsearch15
			(done) /data/jh7x3/multicom_github/multicom/src/meta/hhsearch1.5/script/tm_hhsearch1.5_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/hhsearch1.5/hhsearch1.5_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsearch15
			(done)perl /data/jh7x3/multicom_github/multicom/src/meta/hhsearch1.5/script/domain_identification_from_hhsearch15.pl /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsearch15
			
			(done) /data/jh7x3/multicom_github/multicom/tools/disorder_new/bin/predict_diso.sh hhsearch15/T0967.fasta hhsearch15/T0967.fasta.disorder
			
			
		# hhsearch151
			(done) /data/jh7x3/multicom_github/multicom/src/meta/hhsearch151/script/tm_hhsearch151_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hhsearch151/hhsearch151_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsearch151
				
				
		#csblast
		(done)/data/jh7x3/multicom_github/multicom/src/meta/csblast/script/multicom_csblast_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/csblast/csblast_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta csblast
			
		
		##hhsuite
		(done) /data/jh7x3/multicom_github/multicom/src/meta/hhsuite//script/tm_hhsuite_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hhsuite/hhsuite_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsuite
			
		(done) /data/jh7x3/multicom_github/multicom/src/meta/hhsuite//script/tm_hhsuite_main_simple.pl /data/jh7x3/multicom_github/multicom/src/meta/hhsuite//super_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsuite
			
		(done) /data/jh7x3/multicom_github/multicom/src/meta/hhsuite//script/filter_identical_hhsuite.pl hhsuite
		
		
		# csiblast
			(done)/data/jh7x3/multicom_github/multicom/src/meta/csblast/script/multicom_csiblast_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/csblast/csiblast_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta csiblast
		
		# blast
			(done) /data/jh7x3/multicom_github/multicom/src/meta/blast//script/main_blast_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/blast/cm_option_adv /data/jh7x3/multicom_github/multicom/test/T0967.fasta blast
			(done) /data/jh7x3/multicom_github/multicom/src/meta/hhsearch/script/tm_hhsearch_main_casp8.pl /data/jh7x3/multicom_github/multicom//src/meta/hhsearch/hhsearch_option_cluster_used_in_casp8 /data/jh7x3/multicom_github/multicom/test/T0967.fasta blast 

		# psiblast
			(done) /data/jh7x3/multicom_github/multicom/src/meta/psiblast//script/main_psiblast_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/psiblast/cm_option_adv /data/jh7x3/multicom_github/multicom/test/T0967.fasta psiblast

		# compass
		(done)/data/jh7x3/multicom_github/multicom/src/meta/compass/script/tm_compass_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/compass/compass_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta compass
			/data/jh7x3/multicom_github/multicom/tools/new_compass//compass_search/prep_psiblastali: /lib/ld-linux.so.2: bad ELF interpreter: No such file or directory
		
		# sam
		(done)/data/jh7x3/multicom_github/multicom/src/meta/sam/script/tm_sam_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/sam/sam_option_nr /data/jh7x3/multicom_github/multicom/test/T0967.fasta sam
	
		# prc
			(done) /data/jh7x3/multicom_github/multicom/src/meta/prc/script/tm_prc_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/prc/prc_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta prc

			
		# hmmer
		(done)/data/jh7x3/multicom_github/multicom/src/meta/hmmer/script/tm_hmmer_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/hmmer/hmmer_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hmmer
	
		
		# hmmer3
		(done)/data/jh7x3/multicom_github/multicom/src/meta/hmmer3/script/tm_hmmer3_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hmmer3/hmmer3_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hmmer3


		# raptorx
			(done) /data/jh7x3/multicom_github/multicom/src/meta/raptorx//script/tm_raptorx_main.pl /data/jh7x3/multicom_github/multicom/src/meta/raptorx/raptorx_option_version3 /data/jh7x3/multicom_github/multicom/test/T0967.fasta raptorx
		
	
		# newblast
			(done) /data/jh7x3/multicom_github/multicom/src/meta/newblast//script/newblast.pl /data/jh7x3/multicom_github/multicom/src/meta/newblast/newblast_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta newblast


		# multicom
		(done) /data/jh7x3/multicom_github/multicom/src/meta/multicom//script/multicom_cm_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/multicom/cm_option_adv /data/jh7x3/multicom_github/multicom/test/T0967.fasta multicom
			/data/jh7x3/multicom_github/multicom/src/prosys/script//cm_main_comb_join_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/multicom/cm_option_adv T0967.fasta /data/jh7x3/multicom_github/multicom/test/out/full_length/multicom
			
			
		
		# construct
		(done) /data/jh7x3/multicom_github/multicom/src/meta/construct//script/construct_v9.pl /data/jh7x3/multicom_github/multicom/src/meta/construct/construct_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta /data/jh7x3/multicom_github/multicom/test/out/full_length

		# msa
		(done) /data/jh7x3/multicom_github/multicom/src/meta/msa//script/msa4.pl /data/jh7x3/multicom_github/multicom/src/meta/msa/msa_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta /data/jh7x3/multicom_github/multicom/test/out/full_length


		# hhpred
		(done) /data/jh7x3/multicom_github/multicom/src/meta/hhpred//script/tm_hhpred_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hhpred/hhpred_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhpred
						
				
		# hhblits
			(done) /data/jh7x3/multicom_github/multicom/src/meta/hhblits//script/tm_hhblits_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hhblits/hhblits_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhblits
			(done)/data/jh7x3/multicom_github/multicom/src/meta/hhblits//script/filter_identical_hhblits.pl hhblits

		# hhblits3
			(done) /data/jh7x3/multicom_github/multicom/src/meta/hhblits3//script/tm_hhblits3_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hhblits3/hhblits3_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhblits3
			/data/jh7x3/multicom_github/multicom/src/meta/hhblits3//script/filter_identical_hhblits.pl hhblits3
			
			
			
			
		# muster
			(done) /data/jh7x3/multicom_github/multicom/src/meta/muster//script/tm_muster_main.pl /data/jh7x3/multicom_github/multicom/src/meta/muster/muster_option_version4 /data/jh7x3/multicom_github/multicom/test/T0967.fasta muster
			(done) /data/jh7x3/multicom_github/multicom/src/meta/muster//script/filter_identical_muster.pl muster

		# ffas
			(done) /data/jh7x3/multicom_github/multicom/src/meta/ffas//script/tm_ffas_main.pl /data/jh7x3/multicom_github/multicom/src/meta/ffas/ffas_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta ffas



	cd  /data/jh7x3/multicom_github/multicom/test/out/full_length_hard/
	/data/jh7x3/multicom_github/multicom//src/meta/script/multicom_server_hard_ve.pl /data/jh7x3/multicom_github/multicom/src/meta/test_system/multicom_option_hard_casp13 /data/jh7x3/multicom_github/multicom/test/T0967.fasta /data/jh7x3/multicom_github/multicom/test/out/full_length_hard
	
	
	
		### hhsearch	
		(done) perl /data/jh7x3/multicom_github/multicom/src/meta/hhsearch/script/tm_hhsearch_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/hhsearch/hhsearch_option_hard /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsearch 1>out.log 2>err.log


		### compass
		(done) /data/jh7x3/multicom_github/multicom/src/meta/compass/script/tm_compass_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/compass/compass_option_hard /data/jh7x3/multicom_github/multicom/test/T0967.fasta compass

		###raptorx
		(done)  perl /data/jh7x3/multicom_github/multicom/src/meta/raptorx//script/tm_raptorx_main.pl /data/jh7x3/multicom_github/multicom/src/meta/raptorx/raptorx_option_version3 /data/jh7x3/multicom_github/multicom/test/T0967.fasta raptorx


		###csiblast
		(done) perl /data/jh7x3/multicom_github/multicom/src/meta/csblast/script/multicom_csiblast_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/csblast/csiblast_option_hard /data/jh7x3/multicom_github/multicom/test/T0967.fasta csiblast


		### sam
		(done) /data/jh7x3/multicom_github/multicom/src/meta/sam/script/tm_sam_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/sam/sam_option_hard /data/jh7x3/multicom_github/multicom/test/T0967.fasta sam


		## hmmer
		(done) /data/jh7x3/multicom_github/multicom/src/meta/hmmer/script/tm_hmmer_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/hmmer/hmmer_option_hard /data/jh7x3/multicom_github/multicom/test/T0967.fasta hmmer


		## psiblast
		(done) /data/jh7x3/multicom_github/multicom/src/meta/psiblast//script/main_psiblast_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/psiblast/psiblast_option_hard /data/jh7x3/multicom_github/multicom/test/T0967.fasta psiblast


		##newblast
		(done) /data/jh7x3/multicom_github/multicom/src/meta/newblast//script/newblast.pl /data/jh7x3/multicom_github/multicom/src/meta/newblast/newblast_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta newblast

		## blast
		(done)  /data/jh7x3/multicom_github/multicom/src/meta/blast//script/main_blast_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/blast/cm_option_adv /data/jh7x3/multicom_github/multicom/test/T0967.fasta blast
		(done)/data/jh7x3/multicom_github/multicom/src/meta/hhsearch/script/tm_hhsearch_main_casp8.pl /data/jh7x3/multicom_github/multicom//src/meta/hhsearch/hhsearch_option_cluster_used_in_casp8 /data/jh7x3/multicom_github/multicom/test/T0967.fasta blast 1>out.log 2>err.log


		### hhsearch1.5
		(done) /data/jh7x3/multicom_github/multicom/src/meta/hhsearch1.5/script/tm_hhsearch1.5_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/hhsearch1.5/hhsearch1.5_option_hard /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsearch15

		### prc
		(done) /data/jh7x3/multicom_github/multicom/src/meta/prc/script/tm_prc_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/prc/prc_option_hard /data/jh7x3/multicom_github/multicom/test/T0967.fasta prc

		###construct
		(waiting) /data/jh7x3/multicom_github/multicom/src/meta/construct//script/construct_hard_v9.pl /data/jh7x3/multicom_github/multicom/src/meta/construct/construct_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta /data/jh7x3/multicom_github/multicom/test/out/full_length_hard


		## hhpred
		(done)  /data/jh7x3/multicom_github/multicom/src/meta/hhpred//script/tm_hhpred_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hhpred/hhpred_option_hard /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhpred


		## hhblit
		(done)   /data/jh7x3/multicom_github/multicom/src/meta/hhblits//script/tm_hhblits_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hhblits/hhblits_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhblits
		(done) /data/jh7x3/multicom_github/multicom/src/meta/hhblits//script/filter_identical_hhblits.pl hhblits



		### hhblit3
		(done) /data/jh7x3/multicom_github/multicom/src/meta/hhblits3//script/tm_hhblits3_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hhblits3/hhblits3_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhblits3
		(done) /data/jh7x3/multicom_github/multicom/src/meta/hhblits3//script/filter_identical_hhblits.pl hhblits3

		## ffas
		(done) /data/jh7x3/multicom_github/multicom/src/meta/ffas//script/tm_ffas_main.pl /data/jh7x3/multicom_github/multicom/src/meta/ffas/ffas_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta ffas
		
		
		## hhsuite
		(done) /data/jh7x3/multicom_github/multicom/src/meta/hhsuite//script/tm_hhsuite_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hhsuite/hhsuite_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsuite
		(done)/data/jh7x3/multicom_github/multicom/src/meta/hhsuite//script/tm_hhsuite_main_simple.pl /data/jh7x3/multicom_github/multicom/src/meta/hhsuite//super_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsuite
		(done)/data/jh7x3/multicom_github/multicom/src/meta/hhsuite//script/filter_identical_hhsuite.pl hhsuite


		### muster
		(done)  /data/jh7x3/multicom_github/multicom/src/meta/muster//script/tm_muster_main.pl /data/jh7x3/multicom_github/multicom/src/meta/muster/muster_option_version4 /data/jh7x3/multicom_github/multicom/test/T0967.fasta muster
		(done)/data/jh7x3/multicom_github/multicom/src/meta/muster//script/filter_identical_muster.pl muster

		### hhsearch151
		(done)  /data/jh7x3/multicom_github/multicom/src/meta/hhsearch151/script/tm_hhsearch151_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hhsearch151/hhsearch151_option_hard /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsearch151


		### msa
		(running) /data/jh7x3/multicom_github/multicom/src/meta/msa//script/msa4.pl /data/jh7x3/multicom_github/multicom/src/meta/msa/msa_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta /data/jh7x3/multicom_github/multicom/test/out/full_length_hard

		### confold
		(done) /data/jh7x3/multicom_github/multicom/src/meta/confold2/script/tm_confold2_main.sh /data/jh7x3/multicom_github/multicom/src/meta/confold2/CONFOLD_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta confold
			
			perl /data/jh7x3/multicom_github/multicom/tools/confold2/confold-v2.0/confold2-main-CASP.pl -rr /data/jh7x3/multicom_github/multicom/test/out/full_length_hard/confold/T0967.rr -ss  /data/jh7x3/multicom_github/multicom/test/out/full_length_hard/confold/T0967.ss -out  /data/jh7x3/multicom_github/multicom/test/out/full_length_hard/confold/confold2-T0967
			
			

		### unicon3d
		(done)/data/jh7x3/multicom_github/multicom/src/meta/unicon3d/script/tm_unicon3d_main.pl /data/jh7x3/multicom_github/multicom/src/meta/unicon3d/Unicon3D_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta unicon3d /data/jh7x3/multicom_github/multicom/test/out/full_length_hard/confold/dncon2/T0967.dncon2.rr



		### rosetta
		(done) /data/jh7x3/multicom_github/multicom/src/meta/script/make_rosetta_fragment.sh /data/jh7x3/multicom_github/multicom/test/T0967.fasta abini /data/jh7x3/multicom_github/multicom/test/out/full_length_hard/rosetta_common 100 >/dev/null
						
		(done)  /data/jh7x3/multicom_github/multicom/src/meta/script/run_rosetta_no_fragment.sh /data/jh7x3/multicom_github/multicom/test/T0967.fasta abini rosetta2 100
		
		
		
		### rosettacon
		
		(running)/data/jh7x3/multicom_github/multicom/src/meta/rosettacon/script/tm_rosettacon_main.pl /data/jh7x3/multicom_github/multicom/src/meta/rosettacon/rosettacon_option   /data/jh7x3/multicom_github/multicom/test/T0967.fasta rosettacon /data/jh7x3/multicom_github/multicom/test/out/full_length_hard/confold/dncon2/T0967.dncon2.rr
		
	
	
	

	
### 2019/05/08 test again 

cd  /data/jh7x3/multicom_github/multicom/test/out2/
perl /data/jh7x3/multicom_github/multicom//src/meta/script/multicom_server_ve.pl /data/jh7x3/multicom_github/multicom/src/meta/test_system/multicom_option_casp13 /data/jh7x3/multicom_github/multicom/test/T0967.fasta /data/jh7x3/multicom_github/multicom/test/out2/full_length
	

perl  /data/jh7x3/multicom_github/multicom//src/meta/script/multicom_server_hard_ve.pl /data/jh7x3/multicom_github/multicom/src/meta/test_system/multicom_option_hard_casp13 /data/jh7x3/multicom_github/multicom/test/T0967.fasta /data/jh7x3/multicom_github/multicom/test/out2/full_length_hard
	
perl /data/jh7x3/multicom_github/multicom/src/multicom_ve.pl /data/jh7x3/multicom_github/multicom/src/multicom_system_option_casp13  /data/jh7x3/multicom_github/multicom/test/T0967.fasta  /data/jh7x3/multicom_github/multicom/test/out2

cd  /data/jh7x3/multicom_github/multicom/test/T1023s1/full_length/


perl /data/jh7x3/multicom_github/multicom/src/multicom_ve.pl /data/jh7x3/multicom_github/multicom/src/multicom_system_option_casp13  /data/jh7x3/multicom_github/multicom/test/T1023s1.fasta  /data/jh7x3/multicom_github/multicom/test/T1023s1


Evaluate models based on template, alignments, and structural similarity.
/data/jh7x3/multicom_github/multicom/src/meta//script/analyze_alignments_v3.pl    /data/jh7x3/multicom_github/multicom/test/out2/full_length/meta/   /data/jh7x3/multicom_github/multicom/test/out2/full_length/meta/T0967.align
/data/jh7x3/multicom_github/multicom/src/meta//script/gen_dashboard_v4.pl /data/jh7x3/multicom_github/multicom/test/out2/full_length/meta/ T0967 /data/jh7x3/multicom_github/multicom/test/out2/full_length.dash
Combine full-length models based on based on pairwise GDT-TS or tm-score...
/data/jh7x3/multicom_github/multicom/src/meta//script/combine_models_gdt_tm_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/  /data/jh7x3/multicom_github/multicom/test/out2/full_length/meta/ /data/jh7x3/multicom_github/multicom/test/out2/full_length.dash /data/jh7x3/multicom_github/multicom/test/T0967.fasta /data/jh7x3/multicom_github/multicom/test/out2/mcomb/

		(error)/data/jh7x3/multicom_github/multicom/src/meta//script/stx_model_comb_global.pl /data/jh7x3/multicom_github/multicom/tools/tm_score/TMscore_32 /data/jh7x3/multicom_github/multicom/test/out2/full_length/meta T0967.score /data/jh7x3/multicom_github/multicom/test/T0967.fasta /data/jh7x3/multicom_github/multicom/test/out2/mcomb//T0967.pir 4 0.8 0.70
		
		
		
		

/data/jh7x3/multicom_github/multicom/src/meta//script/top2comb.pl /data/jh7x3/multicom_github/multicom/test/out2/mcomb/ /data/jh7x3/multicom_github/multicom/test/out2/mcomb/consensus.eva 0.88
Combined the models of domains if necessary.
/data/jh7x3/multicom_github/multicom/src/meta//script/convert2casp_v5_simple.pl /data/jh7x3/multicom_github/multicom/src/prosys/ /data/jh7x3/multicom_github/multicom/src/meta/ /data/jh7x3/multicom_github/multicom/test/out2 T0967 /data/jh7x3/multicom_github/multicom/test/T0967.fasta
MULTICOM prediction for T0967 is done.




## single easy: T1023s1
cd  /data/jh7x3/multicom_github/multicom/test/T1023s1//

source /data/jh7x3/multicom_github/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/data/jh7x3/multicom_github/multicom/tools/boost_1_55_0/lib/:/data/jh7x3/multicom_github/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH
perl /data/jh7x3/multicom_github/multicom/src/multicom_ve.pl /data/jh7x3/multicom_github/multicom/src/multicom_system_option_casp13  /data/jh7x3/multicom_github/multicom/test/T1023s1.fasta  /data/jh7x3/multicom_github/multicom/test/T1023s1 &> /data/jh7x3/multicom_github/multicom/test/T1023s1.runlog &


/data/jh7x3/multicom_github/multicom/src/meta//script/combine_models_gdt_tm_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/  /data/jh7x3/multicom_github/multicom/test/T1023s1/full_length/meta/ /data/jh7x3/multicom_github/multicom/test/T1023s1/full_length.dash /data/jh7x3/multicom_github/multicom/test/T1023s1.fasta /data/jh7x3/multicom_github/multicom/test/T1023s1/mcomb/
/data/jh7x3/multicom_github/multicom/src/meta/script/top2comb.pl /data/jh7x3/multicom_github/multicom/test/T1023s1/mcomb/  /data/jh7x3/multicom_github/multicom/test/T1023s1/mcomb/consensus.eva 0.88

## single hard: T1019s2
cd  /data/jh7x3/multicom_github/multicom/test/T1019s2/

source /data/jh7x3/multicom_github/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/data/jh7x3/multicom_github/multicom/tools/boost_1_55_0/lib/:/data/jh7x3/multicom_github/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH
perl /data/jh7x3/multicom_github/multicom/src/multicom_ve.pl /data/jh7x3/multicom_github/multicom/src/multicom_system_option_casp13  /data/jh7x3/multicom_github/multicom/test/T1019s2.fasta  /data/jh7x3/multicom_github/multicom/test/T1019s2 &> /data/jh7x3/multicom_github/multicom/test/T1019s2.runlog &

/data/jh7x3/multicom_github/multicom/src/meta//script/combine_models_gdt_tm_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/  /data/jh7x3/multicom_github/multicom/test/T1019s2/full_length_hard/meta/ /data/jh7x3/multicom_github/multicom/test/T1019s2/full_length.dash /data/jh7x3/multicom_github/multicom/test/T1019s2.fasta /data/jh7x3/multicom_github/multicom/test/T1019s2/mcomb/
/data/jh7x3/multicom_github/multicom/src/meta/script/top2comb.pl /data/jh7x3/multicom_github/multicom/test/T1019s2/mcomb/  /data/jh7x3/multicom_github/multicom/test/T1019s2/mcomb/consensus.eva 0.88


	
## three domain T0978
cd  /data/jh7x3/multicom_github/multicom/test/T0978/

source /data/jh7x3/multicom_github/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/data/jh7x3/multicom_github/multicom/tools/boost_1_55_0/lib/:/data/jh7x3/multicom_github/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH
perl /data/jh7x3/multicom_github/multicom/src/multicom_ve.pl /data/jh7x3/multicom_github/multicom/src/multicom_system_option_casp13  /data/jh7x3/multicom_github/multicom/test/T0978.fasta  /data/jh7x3/multicom_github/multicom/test/T0978 &> /data/jh7x3/multicom_github/multicom/test/T0978.runlog &

	

	
	
