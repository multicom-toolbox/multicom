

cd /data/jh7x3/multicom_github/multicom/installation/check

### check scratch
mkdir scratch
/data/jh7x3/multicom_github/multicom/tools/SCRATCH-1D_1.1/bin/run_SCRATCH-1D_predictors.sh /data/jh7x3/multicom_github/multicom/test/T0967.fasta  /data/jh7x3/multicom_github/multicom/installation/check/scratch/T0967


### check pspro2
mkdir pspro2
(error) /data/jh7x3/multicom_github/multicom/tools/pspro2/bin/predict_ss_sa_cm.sh /data/jh7x3/multicom_github/multicom/test/T0967.fasta  /data/jh7x3/multicom_github/multicom/installation/check/pspro2/test

	/data/jh7x3/multicom_github/multicom/tools/pspro2/server/predict_seq_ss: /lib/ld-linux.so.2: bad ELF interpreter:
	
	

### check modeller






## test multicom local
perl configure.pl /data/jh7x3/multicom_github/multicom


perl /data/jh7x3/multicom_github/multicom/src/multicom_ve.pl /data/jh7x3/multicom_github/multicom/src/multicom_system_option_casp13  /data/jh7x3/multicom_github/multicom/test/T0967.fasta  /data/jh7x3/multicom_github/multicom/test/out

	/data/jh7x3/multicom_github/multicom//src/meta/script/multicom_server_ve.pl /data/jh7x3/multicom_github/multicom/src/meta/test_system/multicom_option_casp13 /data/jh7x3/multicom_github/multicom/test/T0967.fasta /data/jh7x3/multicom_github/multicom/test/out/full_length
	
		# hhsearch
		(done)/data/jh7x3/multicom_github/multicom/src/meta/hhsearch/script/tm_hhsearch_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/hhsearch/hhsearch_option_cluster /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsearch 1>out.log 2>err.log
		
		#hhsearch15
			(running) /data/jh7x3/multicom_github/multicom/src/meta/hhsearch1.5/script/tm_hhsearch1.5_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/hhsearch1.5/hhsearch1.5_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsearch15
			perl /data/jh7x3/multicom_github/multicom/src/meta/hhsearch1.5/script/domain_identification_from_hhsearch15.pl /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsearch15
			/home/casp13/MULTICOM_package/software/disorder_new/bin/predict_diso.sh /data/jh7x3/multicom_github/multicom/test/T0967.fasta /data/jh7x3/multicom_github/multicom/test/out/full_length/hhsearch15/T0967.fasta.disorder

		# hhsearch151
			(error) /data/jh7x3/multicom_github/multicom/src/meta/hhsearch151/script/tm_hhsearch151_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hhsearch151/hhsearch151_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsearch151
				sh: /data/jh7x3/multicom_github/multicom/tools/psipred-2.61/bin/psipred: /lib/ld-linux.so.2: bad ELF interpreter: No such file or directory
				
				
		#csblast
		(done)/data/jh7x3/multicom_github/multicom/src/meta/csblast/script/multicom_csblast_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/csblast/csblast_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta csblast
			/data/jh7x3/multicom_github/multicom/src/meta/hhsuite//script/tm_hhsuite_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hhsuite/hhsuite_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsuite
			/data/jh7x3/multicom_github/multicom/src/meta/hhsuite//script/tm_hhsuite_main_simple.pl /data/jh7x3/multicom_github/multicom/src/meta/hhsuite//super_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhsuite
			/data/jh7x3/multicom_github/multicom/src/meta/hhsuite//script/filter_identical_hhsuite.pl hhsuite
		
		# csiblast
			(done)/data/jh7x3/multicom_github/multicom/src/meta/csblast/script/multicom_csiblast_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/csblast/csiblast_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta csiblast
		
		# blast
			(done) /data/jh7x3/multicom_github/multicom/src/meta/blast//script/main_blast_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/blast/cm_option_adv /data/jh7x3/multicom_github/multicom/test/T0967.fasta blast
			(running) /data/jh7x3/multicom_github/multicom/src/meta/hhsearch/script/tm_hhsearch_main_casp8.pl /data/jh7x3/multicom_github/multicom//src/meta/hhsearch/hhsearch_option_cluster_used_in_casp8 /data/jh7x3/multicom_github/multicom/test/T0967.fasta blast 1>out.log 2>err.log

		# psiblast
			(running) /data/jh7x3/multicom_github/multicom/src/meta/psiblast//script/main_psiblast_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/psiblast/cm_option_adv /data/jh7x3/multicom_github/multicom/test/T0967.fasta psiblast

		# compass
		(error)/data/jh7x3/multicom_github/multicom/src/meta/compass/script/tm_compass_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/compass/compass_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta compass
			/data/jh7x3/multicom_github/multicom/tools/new_compass//compass_search/prep_psiblastali: /lib/ld-linux.so.2: bad ELF interpreter: No such file or directory
		
		# sam
		(error)/data/jh7x3/multicom_github/multicom/src/meta/sam/script/tm_sam_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/sam/sam_option_nr /data/jh7x3/multicom_github/multicom/test/T0967.fasta sam
			-bash: /data/jh7x3/multicom_github/multicom/tools/sam3.5.i686-linux//bin/hmmscore: /lib/ld-linux.so.2: bad ELF interpreter: No such file or directory

		# prc
			(error) /data/jh7x3/multicom_github/multicom/src/meta/prc/script/tm_prc_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/prc/prc_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta prc

			
		# hmmer
		(done)/data/jh7x3/multicom_github/multicom/src/meta/hmmer/script/tm_hmmer_main_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/hmmer/hmmer_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hmmer
	
		
		# hmmer3
		(done)/data/jh7x3/multicom_github/multicom/src/meta/hmmer3/script/tm_hmmer3_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hmmer3/hmmer3_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hmmer3


		# raptorx
			(done) /data/jh7x3/multicom_github/multicom/src/meta/raptorx//script/tm_raptorx_main.pl /data/jh7x3/multicom_github/multicom/src/meta/raptorx/raptorx_option_version3 /data/jh7x3/multicom_github/multicom/test/T0967.fasta raptorx
		
	
		# newblast
			(running) /data/jh7x3/multicom_github/multicom/src/meta/newblast//script/newblast.pl /data/jh7x3/multicom_github/multicom/src/meta/newblast/newblast_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta newblast


		# multicom
		(wait)/data/jh7x3/multicom_github/multicom/src/meta/multicom//script/multicom_cm_v2.pl /data/jh7x3/multicom_github/multicom/src/meta/multicom/cm_option_adv /data/jh7x3/multicom_github/multicom/test/T0967.fasta multicom
		

		# construct
		/data/jh7x3/multicom_github/multicom/src/meta/construct//script/construct_v9.pl /data/jh7x3/multicom_github/multicom/src/meta/construct/construct_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta /data/jh7x3/multicom_github/multicom/test/out/full_length

		# msa
			/data/jh7x3/multicom_github/multicom/src/meta/msa//script/msa4.pl /data/jh7x3/multicom_github/multicom/src/meta/msa/msa_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta /data/jh7x3/multicom_github/multicom/test/out/full_length

		# hhpred
			(error) /data/jh7x3/multicom_github/multicom/src/meta/hhpred//script/tm_hhpred_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hhpred/hhpred_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhpred
				sh: /data/jh7x3/multicom_github/multicom/tools/psipred-2.61/bin/psipred: /lib/ld-linux.so.2: bad ELF interpreter: No such file or directory
				
				
		# hhblits
			(error) /data/jh7x3/multicom_github/multicom/src/meta/hhblits//script/tm_hhblits_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hhblits/hhblits_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhblits
			/data/jh7x3/multicom_github/multicom/src/meta/hhblits//script/filter_identical_hhblits.pl hhblits

		# hhblits3
			(error) /data/jh7x3/multicom_github/multicom/src/meta/hhblits3//script/tm_hhblits3_main.pl /data/jh7x3/multicom_github/multicom/src/meta/hhblits3/hhblits3_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta hhblits3
			/data/jh7x3/multicom_github/multicom/src/meta/hhblits3//script/filter_identical_hhblits.pl hhblits3
			
			sh: /data/jh7x3/multicom_github/multicom/tools/psipred-2.61//bin/psipred: /lib/ld-linux.so.2: bad ELF interpreter: No such file or directory
			
			
			
		# muster
			(done) /data/jh7x3/multicom_github/multicom/src/meta/muster//script/tm_muster_main.pl /data/jh7x3/multicom_github/multicom/src/meta/muster/muster_option_version4 /data/jh7x3/multicom_github/multicom/test/T0967.fasta muster
			/data/jh7x3/multicom_github/multicom/src/meta/muster//script/filter_identical_muster.pl muster

		# ffas
			(error) /data/jh7x3/multicom_github/multicom/src/meta/ffas//script/tm_ffas_main.pl /data/jh7x3/multicom_github/multicom/src/meta/ffas/ffas_option /data/jh7x3/multicom_github/multicom/test/T0967.fasta ffas



