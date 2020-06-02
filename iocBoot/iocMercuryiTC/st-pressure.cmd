## set PRESSURE_NUM before calling
## if PRESSURE_NUM = 1 then the entries for PRESSURE_NUM 1 in this IOC will be used for the setup

stringiftest("PRESSURE", "$(PRESSURE_$(PRESSURE_NUM)=)")

## Load our record instances
$(IFPRESSURE) dbLoadRecords("db/MercuryPressure.db", "P=$(MYPVPREFIX)$(IOCNAME):PRESSURE:$(PRESSURE_NUM):,PORT=L0,BOARD=$(PRESSURE_$(PRESSURE_NUM))")

$(IFPRESSURE) epicsEnvSet(SIM$(PORT_NUM), $(MYPVPREFIX)$(IOCNAME):$(PORT_NUM):SIM)
$(IFPRESSURE) epicsEnvSet(DISABLE$(PORT_NUM), $(MYPVPREFIX)$(IOCNAME):$(PORT_NUM):DISABLE)
