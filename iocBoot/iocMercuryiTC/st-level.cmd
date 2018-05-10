## set LEVEL_NUM before calling
## if LEVEL_NUM = 1 then the entries for LEVEL_NUM 1 in this IOC will be used for the setup

stringiftest("LEVEL", "$(VI_LEVEL_$(LEVEL_NUM)=)")

$(IFLEVEL) calc("PORT_NUM", "$(LEVEL_NUM)+4")
$(IFLEVEL) lvDCOMConfigure("lvfp$(PORT_NUM)", "frontpanel_level", "${MERCURY_ITC}/data/lv_MercuryLevel.xml", "$(LVDCOM_HOST=)", $(LVDCOM_OPTIONS=6), "$(LVDCOM_PROGID=)", "$(LVDCOM_USER=)", "$(LVDCOM_PASS=)")

## Load our record instances
$(IFLEVEL) dbLoadRecords("db/MercuryLevel.db", "P=$(MYPVPREFIX)$(IOCNAME):LEVEL:$(LEVEL_NUM):,port=lvfp$(PORT_NUM)")

$(IFLEVEL) epicsEnvSet(SIM$(PORT_NUM), $(MYPVPREFIX)$(IOCNAME):$(PORT_NUM):SIM)
$(IFLEVEL) epicsEnvSet(DISABLE$(PORT_NUM), $(MYPVPREFIX)$(IOCNAME):$(PORT_NUM):DISABLE)
