#include <iostream>
#include <string>
#include <map>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <math.h>

using namespace std;

double calculate_q( vector < vector <double> >  &a, vector < vector <double> > &b){
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

int main(int argc, char* argv[]){
	char *model_1 = argv[1];
	char *model_2 = argv[2];
	double q_score = 0;
	vector< vector<double> > coord_1;
	vector< vector<double> > coord_2;
/////////////////////////////////////read model 1//////////////////////////////////////////
                        ifstream PDBI(model_1);
                        if(!PDBI){
                                cerr << "Failed to open " << model_1 << "\n";
                                exit(1);
                        }
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
					vector<double> vec;
					vec.push_back(x);
					vec.push_back(y);
					vec.push_back(z);
					coord_1.push_back(vec);
                                        //cout << line_string << "IIIII\n" << x << y << z << "\n";
					//sleep (2);
                                }
                        }
                        PDBI.close();
///////////////////////////////////////////////////////////////////////////////////////////End 

/////////////////////////////////////read model 2//////////////////////////////////////////
                        ifstream PDBJ(model_2);
                        if(!PDBJ){
                                cerr << "Failed to open " << model_2 << "\n";
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
					vector<double> vec;
					vec.push_back(x);
					vec.push_back(y);
					vec.push_back(z);
					coord_2.push_back(vec);	
                                }
                        }
                        PDBJ.close();
///////////////////////////////////////////////////////////////////////////////////////////End
	//cout << coord_1[0];
	cout << "BEFORE q calculation\n";
	q_score = calculate_q(coord_1, coord_2);
	cout << "AFTER q calculation, ";
	cout << "Q_score is " << q_score << "\n\n";
	return 0;
}
