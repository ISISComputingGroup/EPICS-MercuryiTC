## set PRESSURE_NUM before calling
## if PRESSURE_NUM = 1 then the entries for PRESSURE_NUM 1 in this IOC will be used for the setup

stringiftest("PRESSURE", "$(VI_PRESSURE_$(PRESSURE_NUM)=)")

$(IFPRESSURE) calc("PORT_NUM", "$(PRESSURE_NUM)+6")
$(IFPRESSURE) lvDCOMConfigure("lvfp$(PORT_NUM)", "frontpanel_pressure", "${MERCURY_ITC}/data/lv_MercuryPressure.xml", "$(LVDCOM_HOST=)", $(LVDCOM_OPTIONS=6), "$(LVDCOM_PROGID=)", "$(LVDCOM_USER=)", "$(LVDCOM_PASS=)")

## Load our record instances
$(IFPRESSURE) dbLoadRecords("db/MercuryPressure.db", "P=$(MYPVPREFIX)$(IOCNAME):PRESSURE:$(PRESSURE_NUM):,port=lvfp$(PORT_NUM)")

$(IFPRESSURE) epicsEnvSet(SIM$(PORT_NUM), $(MYPVPREFIX)$(IOCNAME):$(PORT_NUM):SIM)
$(IFPRESSURE) epicsEnvSet(DISABLE$(PORT_NUM), $(MYPVPREFIX)$(IOCNAME):$(PORT_NUM):DISABLE)
