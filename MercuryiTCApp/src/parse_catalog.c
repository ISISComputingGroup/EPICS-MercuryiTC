#include <registryFunction.h>
#include <epicsExport.h>
#include <aSubRecord.h>
#include <stdlib.h>
#include <stdio.h>
#include <menuFtype.h>
#include <errlog.h>
#include <epicsString.h>


static long parse_catalog(aSubRecord *prec) {

	char* input = (char*)(prec->a);
    
    epicsOldString temp_devices[64];
    int assigned_temp_devices = 0;
    epicsOldString pres_devices[64];
    int assigned_pres_devices = 0;
    epicsOldString aux_devices[64];
    int assigned_aux_devices = 0;
    epicsOldString htr_devices[64];
    int assigned_htr_devices = 0;
    epicsOldString lvl_devices[64];
    int assigned_lvl_devices = 0;
    
    char* strtok_saveptr;
    char* location;
    char* type;
    char* dev_string;
    
    dev_string = epicsStrtok_r(input, ":", &strtok_saveptr);
    
    while(dev_string) {
            
        if(strcmp(dev_string, "DEV") != 0) {
            errlogSevPrintf(errlogMajor, "parse_catalog: corrupted message, invalid DEV header");
            return 1;
        }
        
        location = epicsStrtok_r(NULL, ":", &strtok_saveptr);
        
        if (location == NULL) {
            errlogSevPrintf(errlogMajor, "parse_catalog: corrupted message, location is NULL");
            return 1;
        }
        
        type = epicsStrtok_r(NULL, ":", &strtok_saveptr);
        
        if (type == NULL) {
            errlogSevPrintf(errlogMajor, "parse_catalog: corrupted message, type is NULL");
            return 1;
        }
        
        if (strcmp(type, "PRES") == 0) {
            strncpy(pres_devices[assigned_pres_devices++], location, MAX_STRING_SIZE);
        } 
        else if (strcmp(type, "TEMP") == 0) {
            strncpy(temp_devices[assigned_temp_devices++], location, MAX_STRING_SIZE);
        }
        else if (strcmp(type, "AUX") == 0) {
            strncpy(aux_devices[assigned_aux_devices++], location, MAX_STRING_SIZE);
        }
        else if (strcmp(type, "HTR") == 0) {
            strncpy(htr_devices[assigned_htr_devices++], location, MAX_STRING_SIZE);
        }
        else if (strcmp(type, "LVL") == 0) {
            strncpy(lvl_devices[assigned_lvl_devices++], location, MAX_STRING_SIZE);
        } 
        else {
            errlogSevPrintf(errlogMajor, "parse_catalog: unknown device type");
            return 1;
        }
        
        dev_string = epicsStrtok_r(NULL, ":", &strtok_saveptr);
    }
    
    
    (epicsOldString*)(prec->vala) = temp_devices;
    (long)(prec->neva) = assigned_temp_devices;
    
    (epicsOldString*)(prec->valb) = pres_devices;
    (long)(prec->nevb) = assigned_pres_devices;
    
    (epicsOldString*)(prec->valc) = lvl_devices;
    (long)(prec->nevc) = assigned_lvl_devices;
    
    (epicsOldString*)(prec->vald) = htr_devices;
    (long)(prec->nevd) = assigned_htr_devices;
    
    (epicsOldString*)(prec->vale) = aux_devices;
    (long)(prec->neve) = assigned_aux_devices;
	

    return 0;
}

epicsRegisterFunction(parse_catalog);
