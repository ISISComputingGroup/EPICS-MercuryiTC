## set TEMP_NUM before calling
## if TEMP_NUM = 1 then the entries for TEMP_NUM 1 in this IOC will be used for the setup

stringiftest("FULL_AUTO_TEMP", "$(FULL_AUTO_TEMP$(TEMP_NUM)=)")

stringiftest("FULL_AUTO_PRESSURE", "$(FULL_AUTO_PRESSURE$(TEMP_NUM)=)")

## Load our record instances
$(IFFULL_AUTO_TEMP) $(IFFULL_AUTO_PRESSURE) dbLoadRecords("db/MercuryFullAuto.db", "P=$(MYPVPREFIX)$(IOCNAME):,PORT=L0,TEMP_CARD=$(FULL_AUTO_TEMP$(TEMP_NUM)=), PRESSURE_CARD=$(FULL_AUTO_PRESSURE$(TEMP_NUM)=),RECSIM=$(RECSIM),DISABLE=$(DISABLE)")
