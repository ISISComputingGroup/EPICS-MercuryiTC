##ISIS## Run IOC initialisation 
< $(IOCSTARTUP)/init.cmd

epicsEnvSet "STREAM_PROTOCOL_PATH" "$(MERCURY_ITC)/data"

## For recsim:
$(IFRECSIM) drvAsynSerialPortConfigure("L0", "$(PORT=NUL)", 0, 1, 0, 0)

# For dev sim devices
$(IFDEVSIM) drvAsynIPPortConfigure("L0", "localhost:$(EMULATOR_PORT=57677)")

## For real device use:
$(IFNOTDEVSIM) $(IFNOTRECSIM) drvAsynSerialPortConfigure("L0", "$(PORT)", 0, 0, 0, 0)
$(IFNOTDEVSIM) $(IFNOTRECSIM) asynSetOption("L0", -1, "baud", "$(BAUD=57600)")
$(IFNOTDEVSIM) $(IFNOTRECSIM) asynSetOption("L0", -1, "bits", "$(BITS=8)")
$(IFNOTDEVSIM) $(IFNOTRECSIM) asynSetOption("L0", -1, "parity", "$(PARITY=none)")
$(IFNOTDEVSIM) $(IFNOTRECSIM) asynSetOption("L0", -1, "stop", "$(STOP=2)")

## Flow control off
$(IFNOTDEVSIM) $(IFNOTRECSIM) asynSetOption("L0", 0, "clocal", "Y")
$(IFNOTDEVSIM) $(IFNOTRECSIM) asynSetOption("L0",0,"crtscts","N")
$(IFNOTDEVSIM) $(IFNOTRECSIM) asynSetOption("L0",0,"ixon","N")
$(IFNOTDEVSIM) $(IFNOTRECSIM) asynSetOption("L0",0,"ixoff","N")

## Load record instances

##ISIS## Load common DB records 
< $(IOCSTARTUP)/dbload.cmd


epicsEnvSet(SIM1, " ")
epicsEnvSet(SIM2, " ")
epicsEnvSet(SIM3, " ")
epicsEnvSet(SIM4, " ")
epicsEnvSet(SIM5, " ")
epicsEnvSet(SIM6, " ")
epicsEnvSet(DISABLE1, " ")
epicsEnvSet(DISABLE2, " ")
epicsEnvSet(DISABLE3, " ")
epicsEnvSet(DISABLE4, " ")
epicsEnvSet(DISABLE5, " ")
epicsEnvSet(DISABLE6, " ")
epicsEnvSet(DISABLE7, " ")
epicsEnvSet(DISABLE8, " ")

epicsEnvSet(TEMP_NUM,1)
< $(MERCURY_ITC)/iocBoot/iocMercuryiTC/st-temp.cmd

epicsEnvSet(TEMP_NUM,2)
< $(MERCURY_ITC)/iocBoot/iocMercuryiTC/st-temp.cmd

epicsEnvSet(TEMP_NUM,3)
< $(MERCURY_ITC)/iocBoot/iocMercuryiTC/st-temp.cmd

epicsEnvSet(TEMP_NUM,4)
< $(MERCURY_ITC)/iocBoot/iocMercuryiTC/st-temp.cmd

epicsEnvSet(LEVEL_NUM,1)
< $(MERCURY_ITC)/iocBoot/iocMercuryiTC/st-level.cmd

epicsEnvSet(LEVEL_NUM,2)
< $(MERCURY_ITC)/iocBoot/iocMercuryiTC/st-level.cmd

epicsEnvSet(PRESSURE_NUM,1)
< $(MERCURY_ITC)/iocBoot/iocMercuryiTC/st-pressure.cmd

epicsEnvSet(PRESSURE_NUM,2)
< $(MERCURY_ITC)/iocBoot/iocMercuryiTC/st-pressure.cmd


dbLoadRecords("db/MercuryGlobal.db", "P=$(MYPVPREFIX)$(IOCNAME):,PORT=L0,RECSIM=$(RECSIM),DISABLE=$(DISABLE)")


##ISIS## Stuff that needs to be done after all records are loaded but before iocInit is called 
< $(IOCSTARTUP)/preiocinit.cmd

cd ${TOP}/iocBoot/${IOC}
iocInit

## Start any sequence programs
#seq sncxxx,"user=hgv27692Host"

##ISIS## Stuff that needs to be done after iocInit is called e.g. sequence programs 
< $(IOCSTARTUP)/postiocinit.cmd
