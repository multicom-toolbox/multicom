#include <iostream>
#include <string>
#include <map>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <math.h>

using namespace std;

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
                                //cout << line_string << "IIIII\n" << x << y << z << "\n";
                                //sleep (2);
                        }
		}
                PDBI.close();
	return coords;
}


double Calculate_Q(char *model_1, char *model_2, vector<char> &align_1, vector<char> &align_2  ){
	vector < vector<double> > a = ReadCa(model_1);
	vector < vector<double> > b = ReadCa(model_2);
	if(align_1.size() != align_2.size()){
		cerr << "Two alignment string have different length!\n";
		exit(1);
	}
	for(int i = 0; i < align_1.size(); i++){
		if(align_1[i] == '-' && align_2[i] != '-'){
			b.erase(b.begin() + i);
		}
                if(align_1[i] != '-' && align_2[i] == '-'){
                        a.erase(a.begin() + i);
                }
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
	avg_q_score = sum_q_score / ( a.size() * (a.size() - 1) / 2 );
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

int main(int argc, char* argv[]){
	char *model_1 = argv[1];
	char *model_2 = argv[2];
	double q_score = 0;
	//q_score = Calculate_Q(coord_1, coord_2);
	cout << "AFTER q calculation, ";
	cout << "Q_score is " << q_score << "\n\n";
	return 0;
}
