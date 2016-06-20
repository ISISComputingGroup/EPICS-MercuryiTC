## set TEMP_NUM before calling
## if TEMP_NUM = 1 then the entries for TEMP_NUM 1 in this IOC will be used for the setup

lvDCOMConfigure("lvfp$(TEMP_NUM)", "frontpanel_temp", "${TOP}/MercuryiTCApp/protocol/lv_MercuryTemp.xml")

## Load our record instances
#dbLoadRecords("db/xxx.db","user=hgv27692Host")
dbLoadRecords("db/MercuryTemp.db", "P=$(MYPVPREFIX)$(IOCNAME):$(TEMP_NUM),port=lvfp$(TEMP_NUM)")
