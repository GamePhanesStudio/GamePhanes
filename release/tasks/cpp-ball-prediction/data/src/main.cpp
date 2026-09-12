#include "Prediction.h"
#include <fstream>
#include <iomanip>
#include <iostream>
#include <string>
int main(int argc, char** argv){if(argc<2){std::cerr<<"usage: pool_predictor <probe.txt>\n";return 1;}std::ifstream in(argv[1]);if(!in){std::cerr<<"cannot open probe\n";return 2;}Ball a,b;int steps=0;std::string tag;while(in>>tag){if(tag=="A")in>>a.pos.x>>a.pos.y>>a.vel.x>>a.vel.y>>a.spin;else if(tag=="B")in>>b.pos.x>>b.pos.y>>b.vel.x>>b.vel.y>>b.spin;else if(tag=="steps")in>>steps;}Prediction::run(a,b,steps);std::cout.setf(std::ios::fixed);std::cout<<std::setprecision(6);std::cout<<"A "<<a.pos.x<<" "<<a.pos.y<<" "<<a.vel.x<<" "<<a.vel.y<<" "<<a.spin<<"\n";std::cout<<"B "<<b.pos.x<<" "<<b.pos.y<<" "<<b.vel.x<<" "<<b.vel.y<<" "<<b.spin<<"\n";return 0;}
