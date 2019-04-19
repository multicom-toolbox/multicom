#include <iostream>
#include <string>
#include <map>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <math.h>
#include <time.h>
#include <sys/types.h>
#include <dirent.h>
#include <errno.h>

using namespace std;

/*int GetDir (char *mydir, vector<string> &files)
{
	DIR *dp;
    	string dir (mydir);
    	struct dirent *dirp;
    	if((dp  = opendir(dir.c_str())) == NULL) {
        	cerr << "Error(" << errno << ") opening " << dir << endl;
        	exit(1);
    	}

    	while ((dirp = readdir(dp)) != NULL) {
        	files.push_back(string(dirp->d_name));
    	}
    	closedir(dp);
    	return 0;
}
*/

vector < vector<double> > ReadCa(char* file){    //Return the Ca coordinates in a two dimensional vector
	vector< vector<double> > coords;
        ifstream PDBI(file);
        	if(!PDBI){
                	cerr << "Failed to open " << file << "\n";
                        exit(1);
                }
                while(!PDBI.eof()){
                	char line[1000];   //###NOTE: maximun 1000 character per line, enough for PDB file
                        PDBI.getline(line, 1000, '\n');
                        string line_string (line);
                        if(line_string.size() < 50){
                        	continue;
                        }
                       	//cout << "size of line" << line_string.size() << "\n";
                        if(line_string.substr(13, 2) == "CA"){
                        	double x = strtod((line_string.substr(30, 8)).c_str(), NULL);
                                double y = strtod((line_string.substr(38, 8)).c_str(), NULL);
                                double z = strtod((line_string.substr(46, 8)).c_str(), NULL);
                                vector<double> vec;
                                vec.push_back(x);
                                vec.push_back(y);
                                vec.push_back(z);
                                coords.push_back(vec);
				vec.clear();
                                //cout << line_string << "IIIII\n" << x << y << z << "\n";
                        }
		}
                PDBI.close();
	//cout << "in the ReadCa " << coords.size() << "\n";
	return coords;
}


double Calculate_Q(vector < vector <double> >  &m, vector < vector <double> > &n, string align_1, string align_2  ){
	vector < vector <double> > a ;
        vector < vector <double> > b ;
	if(align_1.size() != align_2.size()){
		cerr << "Two alignment string have different length!\n";
		exit(1);
	}
	for(int i = 0; i < align_1.size(); i++){
		if(align_1[i] == '-' || align_2[i] == '-'){
			continue;
		}
                if(align_1[i] != align_2[i]){
                        continue;
                }
		int order_1 = 0;
		int order_2 = 0;
		for(int j = 0; j < i; j++){
			if(align_1.substr(j, 1) != "-"){
				order_1++;
			}
                        if(align_2.substr(j, 1) != "-"){
                                order_2++;
                        }
		}
		a.push_back(m[order_1]);  
		b.push_back(n[order_2]); 
	}
	double avg_q_score = 0;
	double sum_q_score = 0;
	if(a.size() != b.size()){
		cerr << "Two Ca lists have different length!\n";
		exit(1);
	}
	for(int i = 0; i < a.size(); i++){
		for(int j = 0; j < i; j++){
			double d1 = sqrt( pow( (a[i][0] - a[j][0]), 2) +  pow( (a[i][1] - a[j][1]), 2) + pow( (a[i][2] - a[j][2]), 2) );
			double d2 = sqrt( pow( (b[i][0] - b[j][0]), 2) +  pow( (b[i][1] - b[j][1]), 2) + pow( (b[i][2] - b[j][2]), 2) ); 
			sum_q_score += exp( - (d1 - d2) * (d1 - d2) );
		}
	}
	if(a.size() > 1){
		avg_q_score = sum_q_score / ( a.size() * (a.size() - 1) / 2 );
	}
	else{
		avg_q_score = 0;
	}
	return (avg_q_score);
}

map<string, string> Parse_TMScore(char *output){
	map<string, string> results;
        string tm_score;
        string gdt_ts;
        string max_sub;
	string num_common;
	string second_model_len;
	string align_1;   
	string align_2;
        int line_counter = 0;
        ifstream TM(output);
        if(!TM){
        	cerr << "Failed to open " << output << "\n";
                exit(1);
        }
        while(!TM.eof()){
        	char line[5000];   //###NOTE: maximun 1000 character per line
                TM.getline(line, 5000, '\n');
                string line_string (line);
                if(line_string.find("There is no common residues in the input structures") != -1){
                	continue;
                }
                if(line_string.find("by which all scores are normalized") != -1){
                	int start = line_string.find("=");
                	second_model_len = line_string.substr((start + 1));
                }
                if(line_string.find("Number of residues in common") != -1){
                        int start = line_string.find("=");
                        num_common = line_string.substr((start + 1));
                }
                if(line_string.substr(0, 8) == "TM-score"){
                	tm_score = line_string.substr(14, 6);
                }
                if(line_string.substr(0, 9) == "GDT-score"){
                        gdt_ts = line_string.substr(14, 6);
                }
                if(line_string.substr(0, 12) == "MaxSub-score"){
                	max_sub = line_string.substr(14, 6);
                }
                if(line_counter == 28){
			align_1 = line_string;
                }
                if(line_counter == 30){
                        align_2 = line_string;
                }
                line_counter++;
	}
        TM.close();
	results["tm_score"] = tm_score;
	results["gdt_ts"] = gdt_ts;
	results["max_sub"] = max_sub;
	results["num_common"] = num_common;
	results["second_model_len"] = second_model_len;
	results["align_1"] = align_1;
	results["align_2"] = align_2;
	return results;
}

int PrintRank( map<double, vector<string> >& mymap, char *file, string target_id){
	map<double, vector<string> >::iterator it;        
	ofstream RANK(file);
        RANK << "PFRMAT QA\nTARGET " << target_id << "\nMODEL 1\nQMODE 1\n";
	for ( it = mymap.end() ; it != mymap.begin(); it-- ){
		if(it == mymap.end()){
			continue;
		}
		for(int i = 0; i < ((*it).second).size(); i++){
			RANK << ((*it).second).at(i) << " " << (*it).first << endl;
		}
        }
	it = mymap.begin();
	for(int i = 0; i < ((*it).second).size(); i++){
		RANK << ((*it).second).at(i) << " " << (*it).first << endl;
	}
	RANK << "END" << endl;
        RANK.close();
	return(0);	
}

int main(int argc, char* argv[]){
        if(argc != 6){
                printf ("Seven parameters needed:\n1. Model list;\n2. seqence file;\n3. tm score executable;\n4. output directory;\n5. target I.D., for example, T0388;\n");
                exit(1);
        }

        char *model_list = argv[1];
        char *query_seq_file = argv[2];
        char *tm_score_exe = argv[3];
        char *output_dir = argv[4];
        char *temp_dir = output_dir;
        string target_id (argv[5]);
	//Convert string to char [];
        char *target_id_char = new char[target_id.size()+1];
        target_id_char[target_id.size()]=0;
        memcpy(target_id_char, target_id.c_str(), target_id.size());
	//Read the Ca into a three-dimensional vector;
	vector < vector< vector < double > > > Ca;
	vector<string> models;

	map<double, vector<string> > tm_map;
        map<double, vector<string> > gdt_ts_map;
        map<double, vector<string> > max_sub_map;
        map<double, vector<string> > q_score_map;
	map<double, vector<string> > average_map;
	map<double, vector<string> > weight_avg_map;


        ifstream IN(model_list);
        if(!IN){
                cerr << "Failed to open " << model_list << "\n";
                exit(1);
        }
        while(!IN.eof()){
                char line[5000];   //###NOTE: maximun 5000 character per line
                IN.getline(line, 5000, '\n');
                if(line[0] == '#' || line[0] == '\0'){
                        continue;
                }
		models.push_back(line);
		Ca.push_back(ReadCa(line));		
        }
        IN.close();

	//Read the sequence and get the sequence length
        ifstream SEQ(query_seq_file);
        string query_seq;
        if(!SEQ){
                cerr << "Failed to open " << query_seq_file << "\n";
                exit(1);
        }
        while(!SEQ.eof()){
                char line[5000];   //###NOTE: maximun 5000 character per line
                SEQ.getline(line, 5000, '\n');
                if(line[0] == '>'){
                        continue;
                }
                query_seq = query_seq.append(line);
        }
        SEQ.close();
        int length_query_seq = query_seq.size();
	//Parwise comparision begins
	for(int i = 0; i < Ca.size(); i++){    //Ca.size() returns the number of models
                double tm_score = 0;
                double gdt_ts = 0;
                double max_sub = 0;
                double q_score = 0;
                int found_i = models[i].find_last_of("/");
                string model_id_i = models[i].substr(found_i + 1);
		int num_substract = 0;    	//For the 0.2 threshold
		for(int j = 0; j < Ca.size() ; j++){
			if(i == j){
				continue;
			}
			cout << "BETWEEN" << models[i] << "AND" << models[j] << "   " << i << '_' << j << " \n";
         		//Get the model's name and use them and the target_id as the file prefix
			int found_j = models[j].find_last_of("/");
                	string model_id_j = models[j].substr(found_j + 1);
			//store the TM parsed result
			map<string, string> results;
			//the command line to execute TM_score
                        char tm_comm[5000];
                        char tm_comm_alter[5000];
                        tm_comm[0] = '\0';
                        tm_comm_alter[0] = '\0';
                        strcat(tm_comm, tm_score_exe);
                        strcat(tm_comm_alter, tm_score_exe);
                        strcat(tm_comm, " ");
                        strcat(tm_comm_alter, " ");
                        char *models_i = new char[models[i].size()+1];
                        models_i[models[i].size()]=0;
                        memcpy(models_i, models[i].c_str(), models[i].size());
                        strcat(tm_comm, models_i);
                        strcat(tm_comm, " ");
                        char *models_j = new char[models[j].size()+1];
                        models_j[models[j].size()]=0;
                        memcpy(models_j, models[j].c_str(), models[j].size());
                        strcat(tm_comm, models_j);
                        strcat(tm_comm, " ");
                        strcat(tm_comm, ">");
                        strcat(tm_comm, " ");
                        strcat(tm_comm_alter, models_j);
                        strcat(tm_comm_alter, " ");
                        strcat(tm_comm_alter, models_i);
                        strcat(tm_comm_alter, " ");
                        strcat(tm_comm_alter, "> ");
				
                        char alter_output[3000];
                        alter_output[0] = '\0';
                        char tm_output[3000];
                        tm_output[0] = '\0';
                        strcat(tm_output, temp_dir);
                        strcat(alter_output, temp_dir);
                        strcat(tm_output, "/");
                        strcat(alter_output, "/");
                        //char i_char [10];

                        char *i_char = new char[model_id_i.size()+1];
                        i_char[model_id_i.size()]=0;
                        memcpy(i_char, model_id_i.c_str(), model_id_i.size());
			char i_number [10];
                        sprintf(i_number, "%d", i);
                        char j_number [10];
                        sprintf(j_number, "%d", j);
			strcat(tm_output, target_id_char);
			strcat(tm_output, "_");
			strcat(tm_output, i_number);
			strcat(tm_output, "_");
			strcat(tm_output, j_number);
			strcat(tm_output, "_");
                        strcat(tm_output, i_char);
                        strcat(tm_output, "_VS_");
                        char *j_char = new char[model_id_j.size()+1];
                        j_char[model_id_j.size()]=0;
                        memcpy(j_char, model_id_j.c_str(), model_id_j.size());
                        strcat(alter_output, target_id_char);
                        strcat(alter_output, "_");
			strcat(alter_output, j_number);
			strcat(alter_output, "_");
			strcat(alter_output, i_number);
			strcat(alter_output, "_");
                        strcat(alter_output, j_char);
                        strcat(alter_output, "_VS_");

                        strcat(tm_output, j_char);
                        strcat(tm_output, ".out");
                        strcat(alter_output, i_char);
                        strcat(alter_output, ".out");
                        strcat(tm_comm, tm_output);
                        strcat(tm_comm_alter, alter_output);
                        cout << tm_comm << endl;
                        cout << tm_comm_alter << endl;

			//See whether it has been executed
			string align_1;
			string align_2;
			int num_common;
			int second_model_len;
                        ifstream ALTER(alter_output);
                        if(!ALTER){
                                system(tm_comm);   //execute TM_score
				results = Parse_TMScore(tm_output);
				second_model_len = atoi(results["second_model_len"].c_str());
				if(strtod(results["tm_score"].c_str(), NULL) > 0.2){
					tm_score += strtod(results["tm_score"].c_str(), NULL) * second_model_len / length_query_seq;
					gdt_ts += strtod(results["gdt_ts"].c_str(), NULL) * second_model_len / length_query_seq;
					max_sub += strtod(results["max_sub"].c_str(), NULL) * second_model_len / length_query_seq;
					num_common = atoi(results["num_common"].c_str());
				}
				else{
					num_substract++;
				}
				align_1 = results["align_1"];
                                align_2 = results["align_2"];
                        }
			else{
                                results = Parse_TMScore(alter_output);
				second_model_len = atoi(results["second_model_len"].c_str());
				if(strtod(results["tm_score"].c_str(), NULL) > 0.2){
                                	tm_score += strtod(results["tm_score"].c_str(), NULL) * second_model_len / length_query_seq;
                                	gdt_ts += strtod(results["gdt_ts"].c_str(), NULL) * second_model_len / length_query_seq;
                                	max_sub += strtod(results["max_sub"].c_str(), NULL) * second_model_len / length_query_seq;
                                	num_common = atoi(results["num_common"].c_str());
				}
				else{
					num_substract++;
				}
                                align_2 = results["align_1"];
                                align_1 = results["align_2"];
			}

			//start Q score calculation
			if(Calculate_Q(Ca[i], Ca[j], align_1, align_2) > 0.2){
				q_score += Calculate_Q(Ca[i], Ca[j], align_1, align_2) * num_common / length_query_seq ;
			}
			cout << q_score << endl;
			cout << "Q score: " << Calculate_Q(Ca[i], Ca[j], align_1, align_2) * num_common / length_query_seq << "\n";
		}
		if(Ca.size() > 1){
			tm_score /= (Ca.size() - 1 - num_substract);
			gdt_ts /= (Ca.size() - 1 - num_substract);
			max_sub /= (Ca.size() - 1 - num_substract);
			q_score /= (Ca.size() - 1 - num_substract);
		}
		else{
			tm_score = 0;
			gdt_ts = 0;
			max_sub = 0;
			q_score = 0;
		}
		//int found = models[i].find_last_of("/");
		//string model_id = models[i].substr(found + 1);
		tm_map[tm_score].push_back(model_id_i);
		max_sub_map[max_sub].push_back(model_id_i);
                q_score_map[q_score].push_back(model_id_i);
                gdt_ts_map[gdt_ts].push_back(model_id_i);
		double avg_score = (tm_score + max_sub + q_score + gdt_ts) / 4;
		average_map[avg_score].push_back(model_id_i);
		cout << "FINAL: " << tm_score << "; " << gdt_ts << "; " << max_sub << "; " << q_score << "\n";
		//sleep(1);
	}
	//Save the ranking into their files;

        char rank_tm[5000];
        strcat(rank_tm, output_dir);
        strcat(rank_tm, "/");
	strcat(rank_tm, target_id_char);
        strcat(rank_tm, ".tm");
	PrintRank(tm_map, rank_tm, target_id);

        char rank_gdt[5000];
        strcat(rank_gdt, output_dir);
        strcat(rank_gdt, "/");
	strcat(rank_gdt, target_id_char);
        strcat(rank_gdt, ".gdt");
	PrintRank(gdt_ts_map, rank_gdt, target_id);

        char rank_max[5000];
        strcat(rank_max, output_dir);
        strcat(rank_max, "/");
	strcat(rank_max, target_id_char);
        strcat(rank_max, ".max");
	PrintRank(max_sub_map, rank_max, target_id);

        char rank_q[5000];
        strcat(rank_q, output_dir);
        strcat(rank_q, "/");
	strcat(rank_q, target_id_char);
        strcat(rank_q, ".q");
	PrintRank(q_score_map, rank_q, target_id);

        char rank_avg[5000];
        strcat(rank_avg, output_dir);
        strcat(rank_avg, "/");
        strcat(rank_avg, target_id_char);
        strcat(rank_avg, ".avg");
        PrintRank(average_map, rank_avg, target_id);

	char del_comm[1000] = "find ";
	strcat(del_comm, output_dir);
	strcat(del_comm, " -name '*out' | xargs rm");
	system(del_comm);	
	cout << del_comm <<endl;

	return 0;
}
