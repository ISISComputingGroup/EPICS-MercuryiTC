/*  For use with the cvt Record. This file produces a not linearly interpreted fit

    The function must be named *** user1DTableSub.c *** because there is no clean way (without significant restructure
    of the cvt record) to pass in a user defined function name AND a clibration file to produce a fit from. 
    Therefore, the record (the backend cvtRecord.c) just looks for a function signature of a hardcoded name

    user1DTableSub

    and calls this. 

    The function creates a spline fit and an accelerator (essentially a lookup table of previously evaluated
    values) and bundles them into a struct to push to the DPVT field so that it can be retrieved each time 
    an evaluation is called. This means that the fit does not need to be produced, nor an accelerator allocated 
    each time the function is called.

    The record backend produces a value by calling 

    value = user1DTableSub(0, 0, 0, 0, pcvt->x, &pcvt->dpvt);

*/

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include <registryFunction.h>
#include <epicsExport.h>
#include <errlog.h>

struct InitData {
    int len_arr;
     double *x_data;
     double *y_data;
};


/*  args:
        int isInit:        flag passed by caller to determine if the fit is being initialised 
        double x_data[]:    array of calibration data
        double y_data[]:    array of calibration data
        int len_arr:        length of x and y arrays
        double x:           value to be evaluated by fit
        void ** dpvt:       pointer to record's dpvt field for storing data between calls       
*/
static double user1DTableSub(int isInit, double x_data[], double y_data[], int len_arr, double x, void ** dpvt) {
    struct InitData *p_initData;
    double val = 0;
    int i;
    if (isInit == 1) {
        p_initData = malloc(sizeof(struct InitData));
        p_initData->len_arr = len_arr;
        p_initData->x_data = malloc(sizeof(double)*p_initData->len_arr);
        p_initData->y_data = malloc(sizeof(double)*p_initData->len_arr);
        for (i=0; i<len_arr; i++) {
            p_initData->x_data[i] = x_data[i];
            p_initData->y_data[i] = y_data[i];
        }
        *dpvt = p_initData;
    }
    else{
        p_initData = (struct InitData *) *dpvt;
        if (p_initData->len_arr > 0) {
        
            // csm_read_1d_table automatically sorts arrays into ascending order. 
            val=p_initData->x_data[0];
            for (i=0; i<p_initData->len_arr; i++){
                if (x < p_initData->x_data[i]) {
                    break;
                }
                val = p_initData->y_data[i];
            }
        }
    }
    return val;
}

epicsRegisterFunction(user1DTableSub);
