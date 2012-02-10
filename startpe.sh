#!/bin/bash
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
#___INFO__MARK_END___

PeHostfile2MPICH() {
   cat $1 | while read line; do
      host=`echo $line|cut -f1 -d" "|cut -f1 -d"."`
      nslots=`echo $line|cut -f2 -d" "`
      i=1
      while [ $i -le $nslots ]; do
         echo $host
         i=`expr $i + 1`
      done
   done
}

PeHostfile2MPICH2(){
    cat $1 | while read line; do
        host=`echo $line|cut -f1 -d" "|cut -f1 -d"."`
        nslots=`echo $line|cut -f2 -d" "`
        echo $host:$nslots
    done
}

PeHostfile2LAMbootSchema(){
    cat $1 | while read line; do
        host=`echo $line|cut -f1 -d" "|cut -f1 -d"."`
        nslots=`echo $line|cut -f2 -d" "`
        echo "$host cpu=$nslots"
    done
}

PeHostfile2Linda(){
    local machines
    while read line; do
       # echo $line
       host=`echo $line|cut -f1 -d" "|cut -f1 -d"."`
       nslots=`echo $line|cut -f2 -d" "`
       if [ -n "$machines" ]; then
          machines="$machines,$host:$nslots"
       else
          machines="$host:$nslots"
       fi
    done < $1
    echo $machines
}

me=`basename $0`

# test number of args
if [ $# -ne 1 ]; then
   echo "$me: got wrong number of arguments" >&2
   exit 1
fi

# get arguments
pe_hostfile=$1

# ensure pe_hostfile is readable
if [ ! -r $pe_hostfile ]; then
   echo "$me: can't read $pe_hostfile" >&2
   exit 1
fi

# create machine-files for MPIs
PeHostfile2MPICH $pe_hostfile >> $TMPDIR/machines.mpich
PeHostfile2MPICH $pe_hostfile >> $TMPDIR/machines.mvapich
PeHostfile2MPICH $pe_hostfile >> $TMPDIR/machines.mvapich2
PeHostfile2MPICH2 $pe_hostfile >> $TMPDIR/machines.mpich2
PeHostfile2MPICH $pe_hostfile >> $TMPDIR/machines.hpmpi
PeHostfile2MPICH2 $pe_hostfile >> $TMPDIR/machines.intelmpi
PeHostfile2Linda $pe_hostfile >> $TMPDIR/machines.linda
PeHostfile2LAMbootSchema $pe_hostfile >> $TMPDIR/machines.lam

mpd_wrapper=%%INSTALL_DIR%%/mpdboot
if [ ! -x $mpd_wrapper ]; then
   echo "$me: can't execute $mpd_wrapper" >&2
   echo "     maybe it resides at a file system not available at this machine" >&2
   exit 1
fi
ln -s %%INSTALL_DIR%%/mpdboot $TMPDIR/mpdboot

# Make script wrapper for 'rsh' available in jobs tmp dir
rsh_wrapper=%%INSTALL_DIR%%/rsh
if [ ! -x $rsh_wrapper ]; then
   echo "$me: can't execute $rsh_wrapper" >&2
   echo "     maybe it resides at a file system not available at this machine" >&2
   exit 1
fi
ln -s $rsh_wrapper $TMPDIR/rsh

# signal success to caller
exit 0
