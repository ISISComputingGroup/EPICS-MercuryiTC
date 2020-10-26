TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

LIBRARY_IOC = MercuryiTC
# MercuryiTC.dbd will be created and installed
DBD += MercuryiTC.dbd

MercuryiTC_DBD += parse_catalog.dbd
MercuryiTC_DBD += full_auto.dbd

MercuryiTC__SRCS += parse_catalog.c full_auto.c user1DTableSub.c
MercuryiTC_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

