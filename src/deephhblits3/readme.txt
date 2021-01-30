
2018 change

1. update pdb hmm database to the latest version in ~/casp8/hhpred/update_db/pdb70

no update any more? 

2. update sequence database (nr20)

to do.

3. since hhblits3 uses the templates in ~/casp8/hhpred/pdb/ to generate models,
there is no need to update its pdb database anymore. we only need to update
its list of pdb templates: ./database/add.list using a program to read all the 
pdbs in ~/casp8/hhpred/pdb

run get_pdb_list.pl to generate the list of PDB templates that can be used by
hhblits3. 

So, it is still important to upate ~/casp8/hhpred/pdb. 


