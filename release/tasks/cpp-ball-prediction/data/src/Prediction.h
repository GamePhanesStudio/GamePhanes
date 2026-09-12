#pragma once
#include <cmath>
struct Vec2{double x=0,y=0;Vec2()=default;Vec2(double X,double Y):x(X),y(Y){}Vec2 operator+(const Vec2&o)const{return{x+o.x,y+o.y};}Vec2 operator-(const Vec2&o)const{return{x-o.x,y-o.y};}Vec2 operator*(double s)const{return{x*s,y*s};}Vec2& operator+=(const Vec2&o){x+=o.x;y+=o.y;return *this;}Vec2& operator-=(const Vec2&o){x-=o.x;y-=o.y;return *this;}};
struct Ball{Vec2 pos,vel;double spin=0;};
class Prediction{public:static void run(Ball&a,Ball&b,int steps){for(int i=0;i<steps;i++)step(a,b);}private:static void step(Ball&a,Ball&b){a.pos+=a.vel;b.pos+=b.vel;a.pos.y+=a.spin*0.002;b.pos.y+=b.spin*0.002;a.spin*=0.99;b.spin*=0.99;a.vel=a.vel*0.995;b.vel=b.vel*0.995;collide(a,b);}static void collide(Ball&a,Ball&b){Vec2 d=a.pos-b.pos;double d2=d.x*d.x+d.y*d.y;if(d2>1.0)return;double dist=std::sqrt(d2<1e-12?1e-12:d2);Vec2 n{d.x/dist,d.y/dist};double va=a.vel.x*n.x+a.vel.y*n.y;double vb=b.vel.x*n.x+b.vel.y*n.y;double j=vb-va;a.vel+=n*j;b.vel-=n*j;}}
