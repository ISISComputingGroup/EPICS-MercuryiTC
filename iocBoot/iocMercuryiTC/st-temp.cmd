## set TEMP_NUM before calling
## if TEMP_NUM = 1 then the entries for TEMP_NUM 1 in this IOC will be used for the setup

stringiftest("TEMP", "$(VI_TEMP_$(TEMP_NUM)=)")

$(IFTEMP) lvDCOMConfigure("lvfp$(TEMP_NUM)", "frontpanel_temp", "${MERCURY_ITC}/data/lv_MercuryTemp.xml")

## Load our record instances
$(IFTEMP) dbLoadRecords("db/MercuryTemp.db", "P=$(MYPVPREFIX)$(IOCNAME):$(TEMP_NUM):,port=lvfp$(TEMP_NUM)")

