program auto_pressure_ctrl("P,PRESSURE_CARD_NUM,TEMP_CARD_NUM")

#include "seqPVmacros.h"
%% #include "seq_snc.h"
%% #include "errlog.h"
%% #include "string.h"

/* Turn on run-time debug messages */
option +d;

/* Make code reentrant. This is needed to run more than one instance of this program. */
option +r;

/* Safe mode */
option +s;

PV(string, statemachine_state, "{P}VTI_SPC:STATEMACHINE:STATE", NoMon);
PV(int, statemachine_enabled, "{P}VTI_SPC:STATEMACHINE:STATUS", Monitor);
PV(double, pressure_sp_min, "{P}VTI_SPC:PRESSURE:SP:MIN", Monitor);
PV(double, pressure_sp_max, "{P}VTI_SPC:PRESSURE:SP:MAX", Monitor);
PV(double, pressure_const, "{P}VTI_SPC:PRESSURE:CONST", Monitor);
PV(double, temperature_cutoff, "{P}VTI_SPC:TEMP:CUTOFF", Monitor);

PV(double, temperature, "{P}{TEMP_CARD_NUM}:TEMP", Monitor);
PV(double, temperature_sp_rbv, "{P}{TEMP_CARD_NUM}:TEMP:SP:RBV", Monitor);
PV(double, pressure_sp_rbv, "{P}PRESSURE:{PRESSURE_CARD_NUM}:PRESSURE:SP:RBV", Monitor);
PV(double, pressure_sp, "{P}PRESSURE:{PRESSURE_CARD_NUM}:PRESSURE:SP", NoMon);

%{
  static const char* const PROGRAM_NAME = "auto_pressure_ctrl.st";

  double new_pressure_sp = 0.0;

  /* This needs to be a macro as the call to pvIndex has to happen from SNL code, not C code. */
  /* See https://www-csr.bessy.de/control/SoftDist/sequencer/EscapeToC.html?highlight=pvindex#calling-pv-functions-from-c */
  #define TRANSITION_TO_STATE(x) state_transition(ssId, pVar, pvIndex(statemachine_state), (x))

  static void state_transition(SS_ID ssId, struct seqg_vars* const pVar, CH_ID index, const char* const new_state_name);

}%

ss auto_pressure_ctrl
{
    state init {
        entry
        {
            TRANSITION_TO_STATE("init");
        }

        when(statemachine_enabled) {
        } state calc_new_sp
    }

    state calc_new_sp {
        entry
        {
            TRANSITION_TO_STATE("calc_new_sp");

            if(temperature <= temperature_sp_rbv) {
              new_pressure_sp = pressure_sp_min;
            } else {
              // Check cutoff for constant vs interpolation calc
              if(temperature_sp_rbv <= temperature_cutoff && temperature <= temperature_cutoff) {
                new_pressure_sp = pressure_const;
              } else {
                // Linear interpolation step
                new_pressure_sp = -1;
              }

              // Check within user-set pressure bounds
              if(new_pressure_sp < pressure_sp_min) {
                new_pressure_sp = pressure_sp_min;
              } else if (new_pressure_sp > pressure_sp_max) {
                new_pressure_sp = pressure_sp_max;
              }
            }
        }

        when(new_pressure_sp != pressure_sp_rbv) {
          PVPUT(pressure_sp, new_pressure_sp);
        } state update_delay

        when(new_pressure_sp == pressure_sp_rbv) {
          // Do nothing.
        } state polling_delay
    }

    state update_delay {
      entry
      {
        TRANSITION_TO_STATE("update_delay");
      }

      when(delay(10)) {
        // Avoid overloading the device.
      } state init
    }

    state polling_delay {
      entry
      {
        TRANSITION_TO_STATE("polling_delay");
      }

      when(delay(1)) {
        // Avoid overloading the processor.
      } state init
    }
}

%{
  /**
   * Called on any state transitions that occur in the state machine - primarily for debugging.
   */
  static void state_transition(SS_ID ssId, struct seqg_vars* const pVar, CH_ID index, const char* const new_state_name)
  {
    strncpy(pVar->statemachine_state, new_state_name, MAX_STRING_SIZE);
	seq_pvPut(ssId, index, SYNC);
	errlogSevPrintf(errlogInfo, "%s: Entering state %s\n", PROGRAM_NAME, new_state_name);
  }
}%
