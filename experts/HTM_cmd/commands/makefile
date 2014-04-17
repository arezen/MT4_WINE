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
TARGET_DIR=$(HOME)/experts/files

PROGS= htm_cmd.csv.example_acc_status      \
       htm_cmd.csv.example_buy             \
       htm_cmd.csv.example_buy_limit       \
       htm_cmd.csv.example_buy_stop        \
       htm_cmd.csv.example_close           \
       htm_cmd.csv.example_delete_pending  \
       htm_cmd.csv.example_modify          \
       htm_cmd.csv.example_get_status      \
       htm_cmd.csv.example_sell            \
       htm_cmd.csv.example_sell_limit      \
       htm_cmd.csv.example_sell_stop       \
       htm_cmd.csv.example_unknown_type    \

all: $(PROGS) 

$(PROGS): dummy
	mkdir -p $(TARGET_DIR)
	cp $@ $(TARGET_DIR)

clean:
dummy:

clobber:
	for i in $(PROGS); do \
	(echo rm -rf $(TARGET_DIR)/$$i); \
	(rm -rf $(TARGET_DIR)/$$i); \
	done;

