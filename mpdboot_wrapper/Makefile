# Makefile
#
# Please don't use make - use "aimk" which invokes make
# Binaries and objects will be created in a subdirectory which has the
# same name as the directory for Grid Engine
#
#___INFO__MARK_BEGIN__
##########################################################################
#
#  The Contents of this file are made available subject to the terms of
#  the Sun Industry Standards Source License Version 1.2
#
#  Sun Microsystems Inc., March, 2001
#
#
#  Sun Industry Standards Source License Version 1.2
#  =================================================
#  The contents of this file are subject to the Sun Industry Standards
#  Source License Version 1.2 (the "License"); You may not use this file
#  except in compliance with the License. You may obtain a copy of the
#  License at http://gridengine.sunsource.net/Gridengine_SISSL_license.html
#
#  Software provided under this License is provided on an "AS IS" basis,
#  WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING,
#  WITHOUT LIMITATION, WARRANTIES THAT THE SOFTWARE IS FREE OF DEFECTS,
#  MERCHANTABLE, FIT FOR A PARTICULAR PURPOSE, OR NON-INFRINGING.
#  See the License for the specific provisions governing your rights and
#  obligations concerning the Software.
#
#  The Initial Developer of the Original Code is: Sun Microsystems, Inc.
#
#  Copyright: 2001 by Sun Microsystems, Inc.
#
#  All Rights Reserved.
#
##########################################################################
#___INFO__MARK_END__

CC          = cc
SHELL       = /bin/sh
MAKE        = make
RM          = rm -f
SDIR        = ..
ALL         = start_mpich2
ALL_OBJS    = start_mpich2.o

#---------------------------------------------------------------------
# rules
#
all: $(ALL)

clean:
	$(RM) $(ALL) $(ALL_OBJS)

#---------------------------------------------------------------------
# starter used in startmpich2.sh
#
start_mpich2: start_mpich2.o
	$(CC) -o start_mpich2 start_mpich2.o $(LFLAGS) $(LIBS)

start_mpich2.o: $(SDIR)/start_mpich2.c
	$(CC) $(CFLAGS) -c $(SDIR)/start_mpich2.c
