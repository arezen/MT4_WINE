######################################################################
#
#       @# Programm
#
#       Copyright (c) Argoden.
#       All Rights Reserved.
#
#       This Module contains Proprietary Information
#       and should be treated as Confidential.
#
#  Author: Aleksander Prokofiev
#  Date:   08/23/2012
#
######################################################################
ROOT=$(HOME)
TARGET_DIR=$(HOME)/experts

DIRS= commands     
PROGS= HTM_cmd-0.1.0.mq4

all: $(DIRS) $(PROGS) 

$(DIRS): dummy
	cd $@; make

$(PROGS): dummy
	mkdir -p $(TARGET_DIR)
	cp $@ $(TARGET_DIR)
	chmod 777 $(TARGET_DIR)/$@

clean:
dummy:
save:
	for i in $(PROGS); do \
	(echo cp $(TARGET_DIR)/$$i .); \
	(cp $(TARGET_DIR)/$$i .); \
	done;

clobber:
	for i in $(PROGS); do \
	(echo rm -rf $(TARGET_DIR)/$$i); \
	(rm -rf $(TARGET_DIR)/$$i); \
	done;
	for i in $(DIRS); do \
        (echo rm -rf $(TARGET_DIR)/$$i); \
        (rm -rf $(TARGET_DIR)/$$i); \
        done;

