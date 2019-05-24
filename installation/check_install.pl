
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
cd /home/casp14/MULTICOM_TS/multicom/tools/DNCON2/dry-run/output/test_T0866

/home/casp14/MULTICOM_TS/multicom/tools/DNCON2/scripts/predict-rr-from-features.sh  feat-T0866.txt  T0866.rr.raw   T0866.feat.stage2.jie.txt



cd /home/casp14/MULTICOM_TS/multicom/tools/DNCON2/dry-run
sh run-3e7u.sh
###########################################



/home/casp14/MULTICOM_TS/multicom/tools/MSACompro_1.2.0


cd /home/casp14/MULTICOM_TS/multicom//installation/check

### check scratch
mkdir scratch
/home/casp14/MULTICOM_TS/multicom/tools/SCRATCH-1D_1.1/bin/run_SCRATCH-1D_predictors.sh /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta  /home/casp14/MULTICOM_TS/multicom//installation/check/scratch/T0967


### check pspro2
mkdir pspro2
(done) /home/casp14/MULTICOM_TS/multicom/tools/pspro2/bin/predict_ss_sa_cm.sh /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta  /home/casp14/MULTICOM_TS/multicom//installation/check/pspro2/test
(done) /home/casp14/MULTICOM_TS/multicom/tools/pspro2/bin/predict_ssa.sh /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta  /home/casp14/MULTICOM_TS/multicom//installation/check/pspro2/test

	

### check modeller

## test multicom local
perl configure.pl /home/casp14/MULTICOM_TS/multicom/

cd  /home/casp14/MULTICOM_TS/multicom//test/out/full_length/


perl /home/casp14/MULTICOM_TS/multicom//src/multicom_ve.pl /home/casp14/MULTICOM_TS/multicom//src/multicom_system_option_casp13  /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta  /home/casp14/MULTICOM_TS/multicom//test/out

	/home/casp14/MULTICOM_TS/multicom///src/meta/script/multicom_server_ve.pl /home/casp14/MULTICOM_TS/multicom//src/meta/test_system/multicom_option_casp13 /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta /home/casp14/MULTICOM_TS/multicom//test/out/full_length
	
		
		
		
		# hhsearch
		(done)/home/casp14/MULTICOM_TS/multicom//src/meta/hhsearch/script/tm_hhsearch_main_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhsearch/hhsearch_option_cluster /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhsearch 1>out.log 2>err.log
		
		
		
		
		
		#hhsearch15
			(done) /home/casp14/MULTICOM_TS/multicom//src/meta/hhsearch1.5/script/tm_hhsearch1.5_main_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhsearch1.5/hhsearch1.5_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhsearch15
			(done)perl /home/casp14/MULTICOM_TS/multicom//src/meta/hhsearch1.5/script/domain_identification_from_hhsearch15.pl /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhsearch15
			
			(done) /home/casp14/MULTICOM_TS/multicom/tools/disorder_new/bin/predict_diso.sh hhsearch15/T0967.fasta hhsearch15/T0967.fasta.disorder
			
			
		# hhsearch151
			(done) /home/casp14/MULTICOM_TS/multicom//src/meta/hhsearch151/script/tm_hhsearch151_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhsearch151/hhsearch151_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhsearch151
				
				
		#csblast
		(done)/home/casp14/MULTICOM_TS/multicom//src/meta/csblast/script/multicom_csblast_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/csblast/csblast_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta csblast
			
		
		##hhsuite
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/hhsuite//script/tm_hhsuite_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhsuite/hhsuite_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhsuite
			
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/hhsuite//script/tm_hhsuite_main_simple.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhsuite//super_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhsuite
			
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/hhsuite//script/filter_identical_hhsuite.pl hhsuite
		
		
		# csiblast
			(done)/home/casp14/MULTICOM_TS/multicom//src/meta/csblast/script/multicom_csiblast_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/csblast/csiblast_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta csiblast
		
		# blast
			(done) /home/casp14/MULTICOM_TS/multicom//src/meta/blast//script/main_blast_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/blast/cm_option_adv /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta blast
			(done) /home/casp14/MULTICOM_TS/multicom//src/meta/hhsearch/script/tm_hhsearch_main_casp8.pl /home/casp14/MULTICOM_TS/multicom///src/meta/hhsearch/hhsearch_option_cluster_used_in_casp8 /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta blast 

		# psiblast
			(done) /home/casp14/MULTICOM_TS/multicom//src/meta/psiblast//script/main_psiblast_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/psiblast/cm_option_adv /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta psiblast

		# compass
		(done)/home/casp14/MULTICOM_TS/multicom//src/meta/compass/script/tm_compass_main_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/compass/compass_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta compass
			/home/casp14/MULTICOM_TS/multicom/tools/new_compass//compass_search/prep_psiblastali: /lib/ld-linux.so.2: bad ELF interpreter: No such file or directory
		
		# sam
		(done)/home/casp14/MULTICOM_TS/multicom//src/meta/sam/script/tm_sam_main_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/sam/sam_option_nr /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta sam
	
		# prc
			(done) /home/casp14/MULTICOM_TS/multicom//src/meta/prc/script/tm_prc_main_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/prc/prc_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta prc

			
		# hmmer
		(done)/home/casp14/MULTICOM_TS/multicom//src/meta/hmmer/script/tm_hmmer_main_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hmmer/hmmer_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hmmer
	
		
		# hmmer3
		(done)/home/casp14/MULTICOM_TS/multicom//src/meta/hmmer3/script/tm_hmmer3_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hmmer3/hmmer3_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hmmer3


		# raptorx
			(done) /home/casp14/MULTICOM_TS/multicom//src/meta/raptorx//script/tm_raptorx_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/raptorx/raptorx_option_version3 /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta raptorx
		
	
		# newblast
			(done) /home/casp14/MULTICOM_TS/multicom//src/meta/newblast//script/newblast.pl /home/casp14/MULTICOM_TS/multicom//src/meta/newblast/newblast_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta newblast


		# multicom
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/multicom//script/multicom_cm_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/multicom/cm_option_adv /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta multicom
			/home/casp14/MULTICOM_TS/multicom//src/prosys/script//cm_main_comb_join_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/multicom/cm_option_adv T0967.fasta /home/casp14/MULTICOM_TS/multicom//test/out/full_length/multicom
			
			
		
		# construct
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/construct//script/construct_v9.pl /home/casp14/MULTICOM_TS/multicom//src/meta/construct/construct_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta /home/casp14/MULTICOM_TS/multicom//test/out/full_length

		# msa
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/msa//script/msa4.pl /home/casp14/MULTICOM_TS/multicom//src/meta/msa/msa_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta /home/casp14/MULTICOM_TS/multicom//test/out/full_length


		# hhpred
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/hhpred//script/tm_hhpred_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhpred/hhpred_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhpred
						
				
		# hhblits
			(done) /home/casp14/MULTICOM_TS/multicom//src/meta/hhblits//script/tm_hhblits_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhblits/hhblits_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhblits
			(done)/home/casp14/MULTICOM_TS/multicom//src/meta/hhblits//script/filter_identical_hhblits.pl hhblits

		# hhblits3
			(done) /home/casp14/MULTICOM_TS/multicom//src/meta/hhblits3//script/tm_hhblits3_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhblits3/hhblits3_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhblits3
			/home/casp14/MULTICOM_TS/multicom//src/meta/hhblits3//script/filter_identical_hhblits.pl hhblits3
			
			
			
			
		# muster
			(done) /home/casp14/MULTICOM_TS/multicom//src/meta/muster//script/tm_muster_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/muster/muster_option_version4 /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta muster
			(done) /home/casp14/MULTICOM_TS/multicom//src/meta/muster//script/filter_identical_muster.pl muster

		# ffas
			(done) /home/casp14/MULTICOM_TS/multicom//src/meta/ffas//script/tm_ffas_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/ffas/ffas_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta ffas



	cd  /home/casp14/MULTICOM_TS/multicom//test/out/full_length_hard/
	/home/casp14/MULTICOM_TS/multicom///src/meta/script/multicom_server_hard_ve.pl /home/casp14/MULTICOM_TS/multicom//src/meta/test_system/multicom_option_hard_casp13 /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta /home/casp14/MULTICOM_TS/multicom//test/out/full_length_hard
	
	
	
		### hhsearch	
		(done) perl /home/casp14/MULTICOM_TS/multicom//src/meta/hhsearch/script/tm_hhsearch_main_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhsearch/hhsearch_option_hard /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhsearch 1>out.log 2>err.log


		### compass
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/compass/script/tm_compass_main_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/compass/compass_option_hard /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta compass

		###raptorx
		(done)  perl /home/casp14/MULTICOM_TS/multicom//src/meta/raptorx//script/tm_raptorx_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/raptorx/raptorx_option_version3 /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta raptorx


		###csiblast
		(done) perl /home/casp14/MULTICOM_TS/multicom//src/meta/csblast/script/multicom_csiblast_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/csblast/csiblast_option_hard /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta csiblast


		### sam
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/sam/script/tm_sam_main_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/sam/sam_option_hard /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta sam


		## hmmer
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/hmmer/script/tm_hmmer_main_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hmmer/hmmer_option_hard /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hmmer


		## psiblast
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/psiblast//script/main_psiblast_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/psiblast/psiblast_option_hard /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta psiblast


		##newblast
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/newblast//script/newblast.pl /home/casp14/MULTICOM_TS/multicom//src/meta/newblast/newblast_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta newblast

		## blast
		(done)  /home/casp14/MULTICOM_TS/multicom//src/meta/blast//script/main_blast_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/blast/cm_option_adv /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta blast
		(done)/home/casp14/MULTICOM_TS/multicom//src/meta/hhsearch/script/tm_hhsearch_main_casp8.pl /home/casp14/MULTICOM_TS/multicom///src/meta/hhsearch/hhsearch_option_cluster_used_in_casp8 /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta blast 1>out.log 2>err.log


		### hhsearch1.5
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/hhsearch1.5/script/tm_hhsearch1.5_main_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhsearch1.5/hhsearch1.5_option_hard /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhsearch15

		### prc
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/prc/script/tm_prc_main_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/prc/prc_option_hard /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta prc

		###construct
		(waiting) /home/casp14/MULTICOM_TS/multicom//src/meta/construct//script/construct_hard_v9.pl /home/casp14/MULTICOM_TS/multicom//src/meta/construct/construct_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta /home/casp14/MULTICOM_TS/multicom//test/out/full_length_hard


		## hhpred
		(done)  /home/casp14/MULTICOM_TS/multicom//src/meta/hhpred//script/tm_hhpred_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhpred/hhpred_option_hard /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhpred


		## hhblit
		(done)   /home/casp14/MULTICOM_TS/multicom//src/meta/hhblits//script/tm_hhblits_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhblits/hhblits_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhblits
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/hhblits//script/filter_identical_hhblits.pl hhblits



		### hhblit3
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/hhblits3//script/tm_hhblits3_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhblits3/hhblits3_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhblits3
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/hhblits3//script/filter_identical_hhblits.pl hhblits3

		## ffas
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/ffas//script/tm_ffas_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/ffas/ffas_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta ffas
		
		
		## hhsuite
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/hhsuite//script/tm_hhsuite_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhsuite/hhsuite_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhsuite
		(done)/home/casp14/MULTICOM_TS/multicom//src/meta/hhsuite//script/tm_hhsuite_main_simple.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhsuite//super_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhsuite
		(done)/home/casp14/MULTICOM_TS/multicom//src/meta/hhsuite//script/filter_identical_hhsuite.pl hhsuite


		### muster
		(done)  /home/casp14/MULTICOM_TS/multicom//src/meta/muster//script/tm_muster_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/muster/muster_option_version4 /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta muster
		(done)/home/casp14/MULTICOM_TS/multicom//src/meta/muster//script/filter_identical_muster.pl muster

		### hhsearch151
		(done)  /home/casp14/MULTICOM_TS/multicom//src/meta/hhsearch151/script/tm_hhsearch151_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/hhsearch151/hhsearch151_option_hard /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta hhsearch151


		### msa
		(running) /home/casp14/MULTICOM_TS/multicom//src/meta/msa//script/msa4.pl /home/casp14/MULTICOM_TS/multicom//src/meta/msa/msa_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta /home/casp14/MULTICOM_TS/multicom//test/out/full_length_hard

		### confold
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/confold2/script/tm_confold2_main.sh /home/casp14/MULTICOM_TS/multicom//src/meta/confold2/CONFOLD_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta confold
			
			perl /home/casp14/MULTICOM_TS/multicom/tools/confold2/confold-v2.0/confold2-main-CASP.pl -rr /home/casp14/MULTICOM_TS/multicom//test/out/full_length_hard/confold/T0967.rr -ss  /home/casp14/MULTICOM_TS/multicom//test/out/full_length_hard/confold/T0967.ss -out  /home/casp14/MULTICOM_TS/multicom//test/out/full_length_hard/confold/confold2-T0967
			
			

		### unicon3d
		(done)/home/casp14/MULTICOM_TS/multicom//src/meta/unicon3d/script/tm_unicon3d_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/unicon3d/Unicon3D_option /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta unicon3d /home/casp14/MULTICOM_TS/multicom//test/out/full_length_hard/confold/dncon2/T0967.dncon2.rr



		### rosetta
		(done) /home/casp14/MULTICOM_TS/multicom//src/meta/script/make_rosetta_fragment.sh /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta abini /home/casp14/MULTICOM_TS/multicom//test/out/full_length_hard/rosetta_common 100 >/dev/null
						
		(done)  /home/casp14/MULTICOM_TS/multicom//src/meta/script/run_rosetta_no_fragment.sh /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta abini rosetta2 100
		
		
		
		### rosettacon
		
		(running)/home/casp14/MULTICOM_TS/multicom//src/meta/rosettacon/script/tm_rosettacon_main.pl /home/casp14/MULTICOM_TS/multicom//src/meta/rosettacon/rosettacon_option   /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta rosettacon /home/casp14/MULTICOM_TS/multicom//test/out/full_length_hard/confold/dncon2/T0967.dncon2.rr
		
	
	
	

	
### 2019/05/08 test again 

cd  /home/casp14/MULTICOM_TS/multicom//test/out2/
perl /home/casp14/MULTICOM_TS/multicom///src/meta/script/multicom_server_ve.pl /home/casp14/MULTICOM_TS/multicom//src/meta/test_system/multicom_option_casp13 /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta /home/casp14/MULTICOM_TS/multicom//test/out2/full_length
	

perl  /home/casp14/MULTICOM_TS/multicom///src/meta/script/multicom_server_hard_ve.pl /home/casp14/MULTICOM_TS/multicom//src/meta/test_system/multicom_option_hard_casp13 /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta /home/casp14/MULTICOM_TS/multicom//test/out2/full_length_hard
	
perl /home/casp14/MULTICOM_TS/multicom//src/multicom_ve.pl /home/casp14/MULTICOM_TS/multicom//src/multicom_system_option_casp13  /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta  /home/casp14/MULTICOM_TS/multicom//test/out2

cd  /home/casp14/MULTICOM_TS/multicom//test/T1023s1/full_length/


perl /home/casp14/MULTICOM_TS/multicom//src/multicom_ve.pl /home/casp14/MULTICOM_TS/multicom//src/multicom_system_option_casp13  /home/casp14/MULTICOM_TS/multicom//test/T1023s1.fasta  /home/casp14/MULTICOM_TS/multicom//test/T1023s1


Evaluate models based on template, alignments, and structural similarity.
/home/casp14/MULTICOM_TS/multicom//src/meta//script/analyze_alignments_v3.pl    /home/casp14/MULTICOM_TS/multicom//test/out2/full_length/meta/   /home/casp14/MULTICOM_TS/multicom//test/out2/full_length/meta/T0967.align
/home/casp14/MULTICOM_TS/multicom//src/meta//script/gen_dashboard_v4.pl /home/casp14/MULTICOM_TS/multicom//test/out2/full_length/meta/ T0967 /home/casp14/MULTICOM_TS/multicom//test/out2/full_length.dash
Combine full-length models based on based on pairwise GDT-TS or tm-score...
/home/casp14/MULTICOM_TS/multicom//src/meta//script/combine_models_gdt_tm_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/  /home/casp14/MULTICOM_TS/multicom//test/out2/full_length/meta/ /home/casp14/MULTICOM_TS/multicom//test/out2/full_length.dash /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta /home/casp14/MULTICOM_TS/multicom//test/out2/mcomb/

		(error)/home/casp14/MULTICOM_TS/multicom//src/meta//script/stx_model_comb_global.pl /home/casp14/MULTICOM_TS/multicom/tools/tm_score/TMscore_32 /home/casp14/MULTICOM_TS/multicom//test/out2/full_length/meta T0967.score /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta /home/casp14/MULTICOM_TS/multicom//test/out2/mcomb//T0967.pir 4 0.8 0.70
		
		
		
		

/home/casp14/MULTICOM_TS/multicom//src/meta//script/top2comb.pl /home/casp14/MULTICOM_TS/multicom//test/out2/mcomb/ /home/casp14/MULTICOM_TS/multicom//test/out2/mcomb/consensus.eva 0.88
Combined the models of domains if necessary.
/home/casp14/MULTICOM_TS/multicom//src/meta//script/convert2casp_v5_simple.pl /home/casp14/MULTICOM_TS/multicom//src/prosys/ /home/casp14/MULTICOM_TS/multicom//src/meta/ /home/casp14/MULTICOM_TS/multicom//test/out2 T0967 /home/casp14/MULTICOM_TS/multicom//test/T0967.fasta
MULTICOM prediction for T0967 is done.




## single easy: T1023s1
cd  /home/casp14/MULTICOM_TS/multicom//test/T1023s1//

source /home/casp14/MULTICOM_TS/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/casp14/MULTICOM_TS/multicom/tools/boost_1_55_0/lib/:/home/casp14/MULTICOM_TS/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH
perl /home/casp14/MULTICOM_TS/multicom//src/multicom_ve.pl /home/casp14/MULTICOM_TS/multicom//src/multicom_system_option_casp13  /home/casp14/MULTICOM_TS/multicom//test/T1023s1.fasta  /home/casp14/MULTICOM_TS/multicom//test/T1023s1 &> /home/casp14/MULTICOM_TS/multicom//test/T1023s1.runlog &


/home/casp14/MULTICOM_TS/multicom//src/meta//script/combine_models_gdt_tm_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/  /home/casp14/MULTICOM_TS/multicom//test/T1023s1/full_length/meta/ /home/casp14/MULTICOM_TS/multicom//test/T1023s1/full_length.dash /home/casp14/MULTICOM_TS/multicom//test/T1023s1.fasta /home/casp14/MULTICOM_TS/multicom//test/T1023s1/mcomb/
/home/casp14/MULTICOM_TS/multicom//src/meta/script/top2comb.pl /home/casp14/MULTICOM_TS/multicom//test/T1023s1/mcomb/  /home/casp14/MULTICOM_TS/multicom//test/T1023s1/mcomb/consensus.eva 0.88

## single hard: T1019s2
cd  /home/casp14/MULTICOM_TS/multicom//test/T1019s2/

source /home/casp14/MULTICOM_TS/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/casp14/MULTICOM_TS/multicom/tools/boost_1_55_0/lib/:/home/casp14/MULTICOM_TS/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH
perl /home/casp14/MULTICOM_TS/multicom//src/multicom_ve.pl /home/casp14/MULTICOM_TS/multicom//src/multicom_system_option_casp13  /home/casp14/MULTICOM_TS/multicom//test/T1019s2.fasta  /home/casp14/MULTICOM_TS/multicom//test/T1019s2 &> /home/casp14/MULTICOM_TS/multicom//test/T1019s2.runlog &

/home/casp14/MULTICOM_TS/multicom//src/meta//script/combine_models_gdt_tm_v2.pl /home/casp14/MULTICOM_TS/multicom//src/meta/  /home/casp14/MULTICOM_TS/multicom//test/T1019s2/full_length_hard/meta/ /home/casp14/MULTICOM_TS/multicom//test/T1019s2/full_length.dash /home/casp14/MULTICOM_TS/multicom//test/T1019s2.fasta /home/casp14/MULTICOM_TS/multicom//test/T1019s2/mcomb/
/home/casp14/MULTICOM_TS/multicom//src/meta/script/top2comb.pl /home/casp14/MULTICOM_TS/multicom//test/T1019s2/mcomb/  /home/casp14/MULTICOM_TS/multicom//test/T1019s2/mcomb/consensus.eva 0.88


	
## three domain T0978
cd  /home/casp14/MULTICOM_TS/multicom//test/T0978/

source /home/casp14/MULTICOM_TS/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/casp14/MULTICOM_TS/multicom/tools/boost_1_55_0/lib/:/home/casp14/MULTICOM_TS/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH
perl /home/casp14/MULTICOM_TS/multicom//src/multicom_ve.pl /home/casp14/MULTICOM_TS/multicom//src/multicom_system_option_casp13  /home/casp14/MULTICOM_TS/multicom//test/T0978.fasta  /home/casp14/MULTICOM_TS/multicom//test/T0978 &> /home/casp14/MULTICOM_TS/multicom//test/T0978.runlog &

	

	
	
