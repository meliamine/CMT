#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "mex.h"

double * equadiff(double * c, double * q, double * H, double * R, double vd, double * c0, double * u, double deltaX, double * ca, double * t) {   
    int lenfile = 50;
    double dH = 0;
    double dt = 0;
    double dc = 0;
    for (int i=0; i<lenfile; i++) {
        dH = H[i+1] - H[i];
        dt = t[i+1] - t[i];
        dc = c[i+1] - c[i];

        if (dH/dt < 0) {
            R[i] = dc/dt - q[i]/H[i] + (vd*c[i])/H[i] - (c0[i] - c[i])*u[i]/deltaX;
        }
        else if (dH/dt > 0) {
            R[i] = dc/dt - q[i]/H[i] - (c0[i]*u[i])/deltaX - (ca[i]*dH)/(H[i]*dt) + (vd/H[i] + u[i]/deltaX + dH/(H[i]*dt));
        }
    }
    return R;

}
