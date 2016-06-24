#!../../bin/windows-x64/MercuryiTC

## You may have to change MercuryiTC to something else
## everywhere it appears in this file

# Increase this if you get <<TRUNCATED>> or discarded messages warnings in your errlog output
errlogInit2(65536, 256)

< envPaths

cd ${TOP}

## Register all support components
dbLoadDatabase "dbd/MercuryiTC.dbd"
MercuryiTC_registerRecordDeviceDriver pdbbase

##ISIS## Run IOC initialisation 
< $(IOCSTARTUP)/init.cmd

## Load record instances

##ISIS## Load common DB records 
< $(IOCSTARTUP)/dbload.cmd

epicsEnvSet(TEMP_NUM,1)
< ${TOP}/iocBoot/${IOC}/st-temp.cmd

epicsEnvSet(TEMP_NUM,2)
< ${TOP}/iocBoot/${IOC}/st-temp.cmd

epicsEnvSet(TEMP_NUM,3)
< ${TOP}/iocBoot/${IOC}/st-temp.cmd

epicsEnvSet(TEMP_NUM,4)
< ${TOP}/iocBoot/${IOC}/st-temp.cmd


##ISIS## Stuff that needs to be done after all records are loaded but before iocInit is called 
< $(IOCSTARTUP)/preiocinit.cmd

cd ${TOP}/iocBoot/${IOC}
iocInit

## Start any sequence programs
#seq sncxxx,"user=hgv27692Host"

##ISIS## Stuff that needs to be done after iocInit is called e.g. sequence programs 
< $(IOCSTARTUP)/postiocinit.cmd
