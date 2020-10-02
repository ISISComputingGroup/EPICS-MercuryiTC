#include <registryFunction.h>
#include <epicsExport.h>
#include <aSubRecord.h>
#include <stdlib.h>
#include <stdio.h>
#include <menuFtype.h>
#include <errlog.h>

/**
 * Settings for full auto mode
 */
struct Settings {
    double deadband;  // temperature deadband 
    double minimum_pressure;  // minimum allowed pressure
    double maximum_pressure;  // maximum allowed pressure
    double offset;  // offset in pressure to ramp up to once the temperature is stable
    double offset_duration;  // time over which to ramp to the pressure in minutes
    double gain_pressure;  // gain of pressure per delta in temperature
};

/**
 * Get the base pressure for a given temperature. 
 * Returns the pressure for the highest temperature below the setpoint from the list.
 * Args:
 *    temp_sp: temperature set point
 * Returns:
 *    base pressure
 */
double get_pressure_from_table(double temp_sp) {
    // currently hard coded will be got from somewhere else
    if (temp_sp < 4)
        return 35;
    if (temp_sp < 10)
        return 35;
    if (temp_sp < 20)
        return 25;
    if (temp_sp < 50)
        return 14;
    if (temp_sp < 100)
        return 10;
    return 8;
    
}

/**
  * Return a value, if it is outside the range return the nearest limit;
  * Args:
  *   value: value to coerce
  *   lim1: limit 1
  *   lim2: limit2
  * Return:
  *    value between lim1 and lim2
  */
double coerce(double value, double lim1, double lim2) {
    double min;
    double max;
    if (lim1 < lim2) {
        min = lim1;
        max = lim2;
    } else {
        min = lim2;
        max = lim1;
    }
    
    if (value < min) {
        value = min;
    } else if (value > max) {
        value = max;
    }
    
    return value;
}

/**
 *  Calculate the ramp pressure based so it ramps from offset down to 0 in duration minutes
 *  Args:
 *     settings: auto flow settings
 *     start_ramp_time: of the ramp in seconds
 *     current_time: in seconds
 *  Returns:
 *      ramp pressure
 */
double pressure_ramp(struct Settings settings, double start_ramp_time, double current_time) {
    double ramp_pressure;
    double duration_in_seconds = settings.offset_duration * 60.0;
    
    // pro-rata amount of pressure to add based on the time since the ramp started
    ramp_pressure = (1.0 - (current_time - start_ramp_time) / duration_in_seconds) * settings.offset;
    
    return coerce(ramp_pressure, 0, settings.offset);

}

/**
  * Get pressure for temperatures above the deadband, excluding offset ramp
  *
  * Args:
  *  settings: settings for full auto
  *  temp: current temp
  *  temp_sp: set point
  * Returns:
  *  pressure
  */
double pressure_above_deadband(struct Settings settings, double temp, double temp_sp) {
    double pressure_from_table;
    
    
    pressure_from_table = get_pressure_from_table(temp_sp);
    double gain_pressure = fabs(temp-temp_sp - settings.deadband) * settings.gain_pressure;
    gain_pressure = pow(gain_pressure, 2);
    double pressure_before_ramp = pressure_from_table + gain_pressure;    

    return coerce(pressure_before_ramp, pressure_from_table, settings.maximum_pressure);
}

/** 
 * Get the pressure for the given temperature and set point.
 *
 * Args:
 *  settings: the settings
 *  temp: curent temperature
 *  temp_sp: temperature setpoint
 *  start_ramp_time: time last ramp started, i.e. last time temperature was outside the deadband
 *  current_time: current ime
 *  pressure: return the pressure that the system should be atan
 * Retruns:
 *   0 for sucess; otherwise error coded
 */
long pressure_for_temp(struct Settings settings, double temp, double temp_sp, double start_ramp_time, double current_time, double* pressure){
    double final_pressure;
    double deadband = settings.deadband;
    
    double delta_temp = temp - temp_sp;
    if ( delta_temp <= -2*deadband) {  
        // a long way under the deadband, set at minimum pressure so temp will rise
        final_pressure = settings.minimum_pressure;
    } else if (delta_temp <= -deadband){
        // below the deadband set at base pressure so temp will rise
        final_pressure = get_pressure_from_table(temp_sp);
    } else if (delta_temp <= deadband){
        // below the deadband set at base pressure so temp will rise
        final_pressure = get_pressure_from_table(temp_sp) + pressure_ramp(settings, start_ramp_time, current_time);
    } else {
        final_pressure = pressure_above_deadband(settings, temp, temp_sp) + pressure_ramp(settings, start_ramp_time, current_time);
    }
    
    *pressure = coerce(final_pressure, settings.minimum_pressure, settings.maximum_pressure);
    return 0;
}

/**
  Routine for asub record to call
  Args:
    pres: pointer to record
  Returns:
    0 sucess; error otherwise
*/
static long calc_pressure(aSubRecord *prec) {

    double temp;
    double temp_sp;
    struct Settings settings;
    long success;
    double pressure;
    double current_time;
    double start_ramp_time;

    if (prec->fta != menuFtypeDOUBLE)
    {
        errlogSevPrintf(errlogMajor, "%s incorrect input argument A type should be DOUBLE", prec->name);
        return 1;
    }
    temp = *(double *)prec->a;
    
    if (prec->ftb != menuFtypeDOUBLE)
    {
        errlogSevPrintf(errlogMajor, "%s incorrect input argument B type should be DOUBLE", prec->name);
        return 1;
    }
    temp_sp = *(double *)prec->b;
    
    if (prec->ftc != menuFtypeDOUBLE)
    {
        errlogSevPrintf(errlogMajor, "%s incorrect input argument C type should be DOUBLE", prec->name);
        return 1;
    }
    settings.deadband = *(double *)prec->c;
    
    if (prec->ftd != menuFtypeDOUBLE)
    {
        errlogSevPrintf(errlogMajor, "%s incorrect input argument D type should be DOUBLE", prec->name);
        return 1;
    }
    settings.minimum_pressure = *(double *)prec->d;
        
    if (prec->fte != menuFtypeDOUBLE)
    {
        errlogSevPrintf(errlogMajor, "%s incorrect input argument E type should be DOUBLE", prec->name);
        return 1;
    }
    settings.maximum_pressure = *(double *)prec->e;
    
    if (prec->ftf != menuFtypeDOUBLE)
    {
        errlogSevPrintf(errlogMajor, "%s incorrect input argument F type should be DOUBLE", prec->name);
        return 1;
    }
    settings.offset = *(double *)prec->f;

    if (prec->ftg != menuFtypeDOUBLE)
    {
        errlogSevPrintf(errlogMajor, "%s incorrect input argument G type should be DOUBLE", prec->name);
        return 1;
    }
    settings.offset_duration = *(double *)prec->g;

    if (prec->fth != menuFtypeDOUBLE)
    {
        errlogSevPrintf(errlogMajor, "%s incorrect input argument H type should be DOUBLE", prec->name);
        return 1;
    }
    current_time = *(double *)prec->h;
    
    if (prec->fti != menuFtypeDOUBLE)
    {
        errlogSevPrintf(errlogMajor, "%s incorrect input argument I type should be DOUBLE", prec->name);
        return 1;
    }
    start_ramp_time = *(double *)prec->i;

    if (prec->ftj != menuFtypeDOUBLE)
    {
        errlogSevPrintf(errlogMajor, "%s incorrect input argument J type should be DOUBLE", prec->name);
        return 1;
    }
    settings.gain_pressure = *(double *)prec->j;

    // reset ramp if temperature is outside the deadband
    if (fabs(temp - temp_sp) > settings.deadband) {
        start_ramp_time = current_time;
    }
    
    success = pressure_for_temp(settings, temp, temp_sp, start_ramp_time, current_time, &pressure);
    
    if (success == 0) {
        *(double*)prec->vala = pressure;
        *(double*)prec->valb = start_ramp_time;
    }
    
    return success;
}

epicsRegisterFunction(calc_pressure);
