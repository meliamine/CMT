#include "mex.h"
#include <limits.h>

#include <stdlib.h>

// the function we refer to
double *equadiff(double * c, double * q, double * H, double vd, double * c0, double * u, double deltaX, double * t, int lenfile);

// equivalent of the main function
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    // Verify that we have the right sizes of inputs and outputs of the function equadiff
    if (nrhs != 8 || nlhs != 1) {
        mexErrMsgIdAndTxt("equadiff:arguments",
                         "8 entrees et 1 sortie requises.");
    }
    
    int lenfile = (int)(mxGetNumberOfElements(prhs[0])-1);

    // Verify types and sizes of variables 
    for (int i = 0; i < nrhs; i++) {

        if (!mxIsDouble(prhs[i]) ||
            mxIsComplex(prhs[i]) ||
            mxIsSparse(prhs[i])) {

            mexErrMsgIdAndTxt("equadiff:type",
                             "Donnees double reelles requises.");
        }

        mwSize n = mxGetNumberOfElements(prhs[i]);

        if (i == 3 || i == 6) {

            if (n != 1) {
                mexErrMsgIdAndTxt("equadiff:scalar",
                                 "Un scalaire est attendu.");
            }

        }
        else {

            mwSize taille_min;

            if (i == 0 || i == 2 || i == 7) {
                taille_min = lenfile + 1;
            }
            else {
                taille_min = lenfile;
            }

            if (n < taille_min ||
                mxGetNumberOfDimensions(prhs[i]) != 2 ||
                (mxGetM(prhs[i]) != 1 &&
                 mxGetN(prhs[i]) != 1)) {

                mexErrMsgIdAndTxt("equadiff:size",
                                 "Vecteur de taille invalide.");
            }
        }
    }
    
// Values of variables are taken from MATLAB to be put in our function
double *c = mxGetDoubles(prhs[0]);
double *q = mxGetDoubles(prhs[1]);
double *H = mxGetDoubles(prhs[2]);
double vd = mxGetScalar(prhs[3]);
double *c0 = mxGetDoubles(prhs[4]);
double *u = mxGetDoubles(prhs[5]);
double deltaX = mxGetScalar(prhs[6]);
double *t = mxGetDoubles(prhs[7]);
    
    
    // Outputs in MATLAB
    plhs[0] = mxCreateDoubleMatrix(lenfile, 1, mxREAL);

    double *R_matlab = mxGetDoubles(plhs[0]);

    // Call of the function
    double *R = equadiff(c, q, H, vd, c0, u, deltaX, t, lenfile);

    // Verify the output
    if (R == NULL) {
        mexErrMsgIdAndTxt("equadiff:memory",
                         "Erreur d'allocation de memoire.");
    }

    // Copy of the results in MATLAB
    for (int i = 0; i < lenfile; i++) {
        R_matlab[i] = R[i];
    }

    // Free the memory allocated for R
    free(R);

                 }


