#!../../bin/windows-x64/MercuryiTC

## You may have to change MercuryiTC to something else
## everywhere it appears in this file

# Increase this if you get <<TRUNCATED>> or discarded messages warnings in your errlog output
errlogInit2(65536, 256)

< envPaths

cd "${TOP}"

## Register all support components
dbLoadDatabase "dbd/MercuryiTC.dbd"
MercuryiTC_registerRecordDeviceDriver pdbbase

## calling common command file
< ${TOP}/iocBoot/${IOC}/st-common.cmd
