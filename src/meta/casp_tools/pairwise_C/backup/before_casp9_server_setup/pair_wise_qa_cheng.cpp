#include <iostream>
#include <string>
#include <map>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <math.h>

using namespace std;

int main(int argc, char* argv[]){
	if(argc != 8){
		printf ("Seven parameters needed:\n1. Model list;\n2. seqence file;\n3. tm score executable;\n4. output directory;\n5. temporary output directory;\n6. target I.D., for example, T0388;\n7. log file;\n");
		exit(1);
	}
	char *model_list = argv[1];
	//string model_list (argv[1]);
	char *query_seq_file = argv[2];
	//string query_seq_file (argv[2]);
	char *tm_score_exe = argv[3];
	char *output_dir = argv[4];
	//string output_dir (argv[4]);
	char *temp_dir = argv[5];
	string target_id (argv[6]);
	string log_file (argv[7]);

	//cout << model_list << "\n";

	map<string, double> models_tm_score;
	map<string, double> models_gdt_ts;
	map<string, double> models_max_sub;
	map<string, double> models_q_score;
	vector<double> models_tm_score_vector;
	vector<double> models_gdt_ts_vector;
	vector<double> models_max_sub_vector;
	vector<double> models_q_score_vector;	

	string models [1000];   //###NOTE: maximum 1000 models
	int num_models = 0;
	
	//char *model_list=new char[model_list.size()+1];
	//model_list[model_list.size()]=0;
	//memcpy(a,model_list.c_str(),model_list.size());

	ifstream IN(model_list);
	if(!IN){
		cerr << "Failed to open " << model_list << "\n";
		exit(1);
	}
	while(!IN.eof()){
		char line[500];   //###NOTE: maximun 500 character per line
		IN.getline(line, 500);
		//cout << line << "\n";
		if(line[0] == '#' || line[0] == '\0'){
			continue;	
		}

		#Cheng comments:  you can diretly change the last character, instead of using a loop
		for(int i = 0; i < strlen(line); i++){
			if(line[i] == '\n'){
				line[i] = '\0';
			}
		}
		//cout << line << "\n";
		models_tm_score[line] = 0;
		models_gdt_ts[line] = 0;
		models_max_sub[line] = 0;
		models_q_score[line] = 0;


		#Cheng comments: you don't need a loop.  why not use only one-line code:  models[num_models] = line;
		for(int i = 0; i < 1000; i++){
			if(models[i].size() < 2){
				models[i] = line;
				break;
			}
		}
		num_models++;
		//cout << num_models << "\n";
	}
	IN.close();
	//cout << num_models << "\n";
	
        ifstream SEQ(query_seq_file);
	string query_seq;
        if(!SEQ){
                cerr << "Failed to open " << query_seq_file << "\n";
                exit(1);
        }
        while(!SEQ.eof()){
                char line[500];   //###NOTE: maximun 500 character per line
                SEQ.getline(line, 500);
                for(int i = 0; i < strlen(line); i++){
                        if(line[i] == '\n'){
                                line[i] = '\0';
                        }
                }
                //cout << line << "\n";
		if(line[0] == '>'){
			continue;
		}
		query_seq = query_seq.append(line);
        }
        SEQ.close();
	int length_query_seq = query_seq.size();
	
	for(int i = 0; i < num_models; i++){
		double sum_tm_score = 0;
		double sum_gdt_ts = 0;
		double sum_max_sub = 0;
		double sum_q_score = 0;
		double avg_tm_score = 0;
		double avg_gdt_ts = 0;
		double avg_max_sub = 0;
		double avg_q_score = 0;
		for(int j = 0; j < num_models ; j++){
			if(i == j){
				continue;
			}
			string align_i;
			string align_j;


			char tm_comm[500];
			char tm_comm_alter[500];
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
			
			char alter_output[300];
			alter_output[0] = '\0';
			char tm_output[300];
			tm_output[0] = '\0';
			strcat(tm_output, temp_dir);
			strcat(alter_output, temp_dir);
			strcat(tm_output, "/");
			strcat(alter_output, "/");
			char i_char [10];
			sprintf(i_char, "%d", i);
			strcat(tm_output, i_char);
			strcat(tm_output, "_");
                        char j_char [10];
                        sprintf(j_char, "%d", j);
			strcat(alter_output, j_char);
                        strcat(alter_output, "_");

                        strcat(tm_output, j_char);
			strcat(tm_output, ".out");
			strcat(alter_output, i_char);
			strcat(alter_output, ".out");
			strcat(tm_comm, tm_output);
			strcat(tm_comm_alter, alter_output);
			
			//cout << tm_comm << "\n" << tm_comm_alter << "\n\n";
			//sleep (2);
		        ifstream ALTER(alter_output);
        		if(!ALTER){
                		system(tm_comm);	
        		}
			//system(tm_comm);
			
			int num_common = 0;
			char file_to_open[300];
			string file_opened;
			if(ALTER){
				for(int m = 0; m < 300; m++){
					file_to_open[m] = alter_output[m];
					file_opened = "alter";
				}	
			} 
			else{
                                for(int m = 0; m < 300; m++){
                                        file_to_open[m] = tm_output[m];
					file_opened = "orig";
                                }
			}
			ALTER.close();
			cout << "file to open is" << file_to_open << "\n";
			//sleep(1);
			//###Open the TM score output ######
			double tm_score;
			double gdt_ts;
			double max_sub;
			int line_counter = 0;
			int second_model_len = 0;
			ifstream TM(file_to_open);
        		if(!TM){
                		cerr << "Failed to open " << file_to_open << "\n";
                		exit(1);
        		}
        		while(!TM.eof()){
                		char line[1000];   //###NOTE: maximun 1000 character per line
                		TM.getline(line, 1000);
				string line_string (line);
				//cout << "line is" << line_string << "\n";
				//sleep (1);
				if(line_string.find("There is no common residues in the input structures") != -1){
					continue;
				}
                		for(int i = 0; i < strlen(line); i++){
                        		if(line[i] == '\n'){
                                		line[i] = '\0';
                        		}
                		}
				if(line_string.find("by which all scores are normalized") != -1){
					int start = line_string.find("=");
					string second_str = line_string.substr((start + 1));
					second_model_len = atoi(second_str.c_str());
				}
				if(line_string.find("Number of residues in common") != -1){
					int start = line_string.find("=");
					string common_str = line_string.substr((start + 1));
					num_common = atoi(common_str.c_str());  //convert c++ string to C string, then convert string to integer;
					//cout << num_common;
				}
				if(line_string.substr(0, 8) == "TM-score"){
					tm_score = strtod((line_string.substr(14, 6)).c_str(), NULL);
					//cout << tm_score ;
				}
                                if(line_string.substr(0, 9) == "GDT-score"){
                                        gdt_ts = strtod((line_string.substr(14, 6)).c_str(), NULL);
                                        //cout << gdt_ts ;
                                }
                                if(line_string.substr(0, 12) == "MaxSub-score"){
                                        max_sub = strtod((line_string.substr(14, 6)).c_str(), NULL);
                                        //cout << max_sub ;
                                }
				if(line_counter == 28){
					if(file_opened == "alter"){
						align_j = line_string;
					}
					if(file_opened == "orig"){
						align_i = line_string;
					}
				}
				if(line_counter == 30){
					if(file_opened == "alter"){
						align_i = line_string;
					}
					if(file_opened == "orig"){
						align_j = line_string;
					}
				}
				line_counter++;
        		}
        		TM.close();
			cout << "TM done\n";
			//cout << "align i and j is" << align_i << "\n" << align_j << "\n";
			//sleep(1);
//START_TM_A
/*
                        ifstream TMA(alter_output);
                        if(!TMA){
                                cerr << "Failed to open " << alter_output << "\n";
                                exit(1);
                        }
                        while(!TMA.eof()){
                                char line[1000];   //###NOTE: maximun 1000 character per line
                                TMA.getline(line, 1000, '\n');
                                string line_string (line);
                                //cout << "line is" << line_string << "\n";
                                //sleep (1);
                                if(line_string.find("There is no common residues in the input structures") != -1){
                                        continue;
                                }
                                for(int i = 0; i < strlen(line); i++){
                                        if(line[i] == '\n'){
                                                line[i] = '\0';
                                        }
                                }
                                //if(line_string.find("Number of residues in common") != -1){
                                //        int start = line_string.find("=");
                                //        string common_str = line_string.substr((start + 1));
                                //        num_common = atoi(common_str.c_str());  //convert c++ string to C string, then convert string to integer;
                                //        //cout << num_common;
                                //}
                                if(line_string.substr(0, 8) == "TM-score"){
                                        tm_score = (tm_score + strtod((line_string.substr(14, 6)).c_str(), NULL)) / 2;
                                        //cout << tm_score ;
                                }
                                if(line_string.substr(0, 9) == "GDT-score"){
                                        gdt_ts = (gdt_ts + strtod((line_string.substr(14, 6)).c_str(), NULL)) / 2;
                                        //cout << gdt_ts ;
                                }
                                if(line_string.substr(0, 12) == "MaxSub-score"){
                                        max_sub = (max_sub + strtod((line_string.substr(14, 6)).c_str(), NULL)) / 2;
                                        //cout << max_sub ;
                                }
                                //if(line_counter == 28){
                                //        align_i = line_string;
                                //}
                                //if(line_counter == 30){
                                //        align_j = line_string;
                                //}
                                line_counter++;
                        }
                        TMA.close();

*/
//END_TM_A
			if(length_query_seq != 0 ){
				tm_score = tm_score * second_model_len / length_query_seq;
				gdt_ts = gdt_ts * second_model_len / length_query_seq;
				max_sub = max_sub * second_model_len / length_query_seq;
			}
			else{
				tm_score = 0;
				gdt_ts = 0;
				max_sub = 0;
			}
			//cout<<"over\n";
			sum_tm_score += tm_score;
			sum_gdt_ts += gdt_ts;
			sum_max_sub += max_sub;
			//cout << "before Q score\n";
			//#########################################################
			//###############Calculate the Q scores####################
			//#########################################################
			string ca_i[2000];   //###NOTE: protein maximum can have 2000 aa.
			string ca_j[2000];
			//###Get the coordinates for the CA atom		
                        ifstream PDBI(models_i);
                        if(!PDBI){
                                cerr << "Failed to open " << models_i << "\n";
                                exit(1);
                        }
			int counter_i_lines = 0;
                        while(!PDBI.eof()){
                                char line[1000];   //###NOTE: maximun 1000 character per line
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
					counter_i_lines++;
					//cout << line_string << "IIIII\n" << x << y << z << "\n";
                                	for(int m = 0; m < 2000; m++){
                                        	if(ca_i[m].empty()){
							//cout << "m is:" << m << "\n";
                                                	char to_print[1000];
							to_print[0] = '\0';
							char x_char[20];
                                                	sprintf(x_char, "%f", x);
                                                	strcat(to_print, x_char);
							strcat(to_print, ";");
							char y_char[20];
							sprintf(y_char, "%f", y);
							strcat(to_print, y_char);
							strcat(to_print, ";");
                                                        char z_char[20];
                                                        sprintf(z_char, "%f", z);
                                                        strcat(to_print, z_char);
                                                        strcat(to_print, ";");
							ca_i[m] = to_print;
							string test(to_print);
                                                	//cout <<"content of ca i is" <<ca_i[m] << "\n";
							//sleep (1);
							//cout << "m is " << m << "\n"; 
                                        		//counter_i_lines++;
							break;
						}
                                	}
				}
			}
			PDBI.close();
			//cout << "counter i lines is"<<counter_i_lines<<"\n";
			//sleep(1);
//start_j

                        ifstream PDBJ(models_j);
                        if(!PDBJ){
                                cerr << "Failed to open " << models_j << "\n";
                                exit(1);
                        }
                        while(!PDBJ.eof()){
                                char line[1000];   //###NOTE: maximun 1000 character per line
                                PDBJ.getline(line, 1000, '\n');
                                string line_string (line);
                                if(line_string.size() < 50){
                                        continue;
                                }
                                //cout << "size of line" << line_string.size() << "\n";
                                if(line_string.substr(13, 2) == "CA"){
                                        double x = strtod((line_string.substr(30, 8)).c_str(), NULL);
                                        double y = strtod((line_string.substr(38, 8)).c_str(), NULL);
                                        double z = strtod((line_string.substr(46, 8)).c_str(), NULL);
                                        //cout << line_string << "JJJJJ\n" << x << y << z << "\n";
                                        for(int m = 0; m < 2000; m++){
                                                if(ca_j[m].empty()){
                                                        char to_print[1000];
                                                        to_print[0] = '\0';
                                                        char x_char[20];
                                                        sprintf(x_char, "%f", x);
                                                        strcat(to_print, x_char);
                                                        strcat(to_print, ";");
                                                        char y_char[20];
                                                        sprintf(y_char, "%f", y);
                                                        strcat(to_print, y_char);
                                                        strcat(to_print, ";");
                                                        char z_char[20];
                                                        sprintf(z_char, "%f", z);
                                                        strcat(to_print, z_char);
                                                        strcat(to_print, ";");
                                                        ca_j[m] = to_print;
                                                        //cout <<"content of ca j is" <<ca_j[m] << "\n";
                                                        break;
                                                }
                                        }
                                }
                        }
                        PDBJ.close();
//end_j
			int counter_p_q = 0;
			double sum_q_score_p_q = 0;
			//cout << "align i size is" << align_i.size() << "\n";
			//cout << "89th cell in i is" << ca_i[89] << "\n";
			//sleep (2);
			for(int atom_p = 0; atom_p < align_i.size(); atom_p++){
				//cout << "atom p is" << atom_p << "\n";
				for(int atom_q = 0; atom_q < align_i.size(); atom_q++){
					if(atom_p <= atom_q){
						continue;
					}
					if(align_i.substr(atom_p, 1) == "-" || align_i.substr(atom_q, 1) == "-" || align_j.substr(atom_p, 1) == "-" || align_j.substr(atom_q, 1) == "-"){
						continue;
					}
					int order_i_p = 0;
					int counter_i_p = 0;
					while(counter_i_p <= atom_p){
						//cout << "align_i is " << align_i.substr(counter_i_p, 1) << "\n";
						if(align_i.substr(counter_i_p, 1) != "-"){
							order_i_p++;
							//cout << "order i p is"<<order_i_p<<"\n";
							if(order_i_p <= 3){
								//sleep (2);
							}
						}
						counter_i_p++;
					}
					int order_i_q = 0;
					int counter_i_q = 0;
					while(counter_i_q <= atom_q){
						if(align_i.substr(counter_i_q, 1) != "-"){
							order_i_q++;
						}
						counter_i_q++;
					}
					//cout << "order i p is:" << order_i_p << "\n";
					//cout << "order i q is:" << order_i_q << "\n";
					string coords_i_p = ca_i[order_i_p - 1];
					string coords_i_q = ca_i[order_i_q - 1];
					//cout << "length of coords_i_p is" << coords_i_p.size() << coords_i_p << "\n";
					//cout << "length of coords_i_q is" << coords_i_q.size() << coords_i_q << "\n";
					//sleep (1);
					vector<string> items_i_p;
					string temp;
					for(int m = 0; m < coords_i_p.size(); m++){
						if(coords_i_p.substr(m, 1) != ";"){
							temp.append(coords_i_p.substr(m, 1));
						}
						else{
							items_i_p.push_back(temp);
							temp.clear();
						}
					}
					items_i_p.push_back(temp);
					//cout << items_i_p[0] << items_i_p[1] << items_i_p[2] << "\n";

                                        vector<string> items_i_q;
                                        temp.clear();
                                        for(int m = 0; m < coords_i_q.size(); m++){
                                                if(coords_i_q.substr(m, 1) != ";"){
                                                        temp.append(coords_i_q.substr(m, 1));
                                                }
                                                else{
                                                        items_i_q.push_back(temp);
                                                        temp.clear();
                                                }
                                        }
                                        items_i_q.push_back(temp);
                                        //cout << items_i_q[0] << items_i_q[1] << items_i_q[2] << "\n";
					double dist_i_p_q = sqrt( (strtod(items_i_p[0].c_str(), NULL) - strtod(items_i_q[0].c_str(), NULL)) * (strtod(items_i_p[0].c_str(), NULL) - strtod(items_i_q[0].c_str(), NULL)) + (strtod(items_i_p[1].c_str(), NULL) - strtod(items_i_q[1].c_str(), NULL)) * (strtod(items_i_p[1].c_str(), NULL) - strtod(items_i_q[1].c_str(), NULL)) + (strtod(items_i_p[2].c_str(), NULL) - strtod(items_i_q[2].c_str(), NULL)) * (strtod(items_i_p[2].c_str(), NULL) - strtod(items_i_q[2].c_str(), NULL))  );
					//cout << "distance of i is" << dist_i_p_q << "\n";

//Start_j
                                        int order_j_p = 0;
                                        int counter_j_p = 0;
                                        while(counter_j_p <= atom_p){
                                                if(align_j.substr(counter_j_p, 1) != "-"){
                                                        order_j_p++;
                                                }
                                                counter_j_p++;
                                        }
                                        int order_j_q = 0;
                                        int counter_j_q = 0;
                                        while(counter_j_q <= atom_q){
                                                if(align_j.substr(counter_j_q, 1) != "-"){
                                                        order_j_q++;
                                                }
                                                counter_j_q++;
                                        }
                                        string coords_j_p = ca_j[order_j_p - 1];
                                        string coords_j_q = ca_j[order_j_q - 1];
                                        //cout << "length of coords_j_p is" << coords_j_p.size() << coords_j_p << "\n";
                                        //cout << "length of coords_j_q is" << coords_j_q.size() << coords_j_q << "\n";
                                        //sleep (1);
                                        vector<string> items_j_p;
                                        temp.clear();
                                        for(int m = 0; m < coords_j_p.size(); m++){
                                                if(coords_j_p.substr(m, 1) != ";"){
                                                        temp.append(coords_j_p.substr(m, 1));
                                                }
                                                else{
                                                        items_j_p.push_back(temp);
                                                        temp.clear();
                                                }
                                        }
                                        items_j_p.push_back(temp);
                                        //cout << items_j_p[0] << items_j_p[1] << items_j_p[2] << "\n";

                                        vector<string> items_j_q;
                                        temp.clear();
                                        for(int m = 0; m < coords_j_q.size(); m++){
                                                if(coords_j_q.substr(m, 1) != ";"){
                                                        temp.append(coords_j_q.substr(m, 1));
                                                }
                                                else{
                                                        items_j_q.push_back(temp);
                                                        temp.clear();
                                                }
                                        }
                                        items_j_q.push_back(temp);
                                        //cout << items_j_q[0] << items_j_q[1] << items_j_q[2] << "\n";
                                        double dist_j_p_q = sqrt( (strtod(items_j_p[0].c_str(), NULL) - strtod(items_j_q[0].c_str(), NULL)) * (strtod(items_j_p[0].c_str(), NULL) - strtod(items_j_q[0].c_str(), NULL)) + (strtod(items_j_p[1].c_str(), NULL) - strtod(items_j_q[1].c_str(), NULL)) * (strtod(items_j_p[1].c_str(), NULL) - strtod(items_j_q[1].c_str(), NULL)) + (strtod(items_j_p[2].c_str(), NULL) - strtod(items_j_q[2].c_str(), NULL)) * (strtod(items_j_p[2].c_str(), NULL) - strtod(items_j_q[2].c_str(), NULL))  );
                                        //cout << "distance of j is" << dist_j_p_q << "\n";
//End_j
					double q_score_p_q = exp( - (dist_i_p_q - dist_j_p_q) * (dist_i_p_q - dist_j_p_q) );
					counter_p_q ++;
					sum_q_score_p_q += q_score_p_q;

				}
			}
			double q_score_i_j = 0;
			if(counter_p_q != 0){
				q_score_i_j = sum_q_score_p_q / counter_p_q;
			}
			if(length_query_seq != 0){
				q_score_i_j = q_score_i_j * num_common / length_query_seq;
			}	
			sum_q_score += q_score_i_j;
			cout << "Q score done\n";
		}
		avg_tm_score = sum_tm_score / (num_models - 1);
	        avg_gdt_ts = sum_gdt_ts / (num_models - 1);
        	avg_max_sub = sum_max_sub / (num_models - 1);
	        avg_q_score = sum_q_score / (num_models - 1);
        	models_tm_score[models[i]] = avg_tm_score;
        	models_gdt_ts[models[i]] = avg_gdt_ts;
        	models_max_sub[models[i]] = avg_max_sub;
        	models_q_score[models[i]] = avg_q_score;
		models_tm_score_vector.push_back(avg_tm_score);
		models_gdt_ts_vector.push_back(avg_gdt_ts);
		models_max_sub_vector.push_back(avg_max_sub);
		models_q_score_vector.push_back(avg_q_score);
	}
	char rank_tm[500];
	strcat(rank_tm, output_dir);
	strcat(rank_tm, "/");
	strcat(rank_tm, "rank_TM");	
	ofstream RANK_TM(rank_tm);
	RANK_TM << "PFRMAT QA\nTARGET " << target_id << "\nMODEL 1\nQMODE 1\n";

	RANK_TM.close();
	

	









	return 0;
	
}
