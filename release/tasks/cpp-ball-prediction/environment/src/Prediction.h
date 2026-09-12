#pragma once
#include <cmath>
struct Vec2 { double x=0, y=0; Vec2()=default; Vec2(double X,double Y):x(X),y(Y){} };
struct Ball { Vec2 pos, vel; double spin=0; };
class Prediction {
public:
    static void run(Ball& a, Ball& b, int steps) {}
};
