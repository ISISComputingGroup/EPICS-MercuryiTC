program auto_pressure_ctrl("P")

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

PV(string, statemachine_state, "{P}STATEMACHINE:STATE", NoMon);
PV(int, statemachine_enabled, "{P}STATEMACHINE:STATUS", Monitor);

%{
  static const char* const PROGRAM_NAME = "auto_pressure_ctrl.st";

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
        }

        when(0) {

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
