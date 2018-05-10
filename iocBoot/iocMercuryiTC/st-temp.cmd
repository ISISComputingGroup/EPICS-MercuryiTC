## set TEMP_NUM before calling
## if TEMP_NUM = 1 then the entries for TEMP_NUM 1 in this IOC will be used for the setup

stringiftest("TEMP", "$(VI_TEMP_$(TEMP_NUM)=)")

$(IFTEMP) lvDCOMConfigure("lvfp$(TEMP_NUM)", "frontpanel_temp", "${MERCURY_ITC}/data/lv_MercuryTemp.xml", "$(LVDCOM_HOST=)", $(LVDCOM_OPTIONS=6), "$(LVDCOM_PROGID=)", "$(LVDCOM_USER=)", "$(LVDCOM_PASS=)")

## Load our record instances
$(IFTEMP) dbLoadRecords("db/MercuryTemp.db", "P=$(MYPVPREFIX)$(IOCNAME):$(TEMP_NUM):,port=lvfp$(TEMP_NUM)")

$(IFTEMP) epicsEnvSet(SIM$(TEMP_NUM), $(MYPVPREFIX)$(IOCNAME):$(TEMP_NUM):SIM)
$(IFTEMP) epicsEnvSet(DISABLE$(TEMP_NUM), $(MYPVPREFIX)$(IOCNAME):$(TEMP_NUM):DISABLE)
