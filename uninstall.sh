#!/bin/bash
#
# Copyright 2012, Brian Smith
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# Uninstall script
#

# remove PEs

export installDir=$1
if [ -z "$installDir" ]; then
    echo "Please specify an installation directory! Exiting..."
    exit 1
fi
export QUEUE_PREFIX=gepetools

ppns=( 1 2 4 6 8 12 16 )

if [ -d $installDir -a -f $installDir/.gepetools.install ]; then
    sudo rm -rf $installDir/
else
    echo "Specified installation directory, '$installDir', appears invalid! Bailing..."
    exit 1
fi

for queue in $(qconf -sql); do
    for pe in $(qconf -spl | grep ${QUEUE_PREFIX}_${queue}); do
        qconf -dattr queue pe_list $pe $queue
    done
done

for pe in $(qconf -spl | grep "${QUEUE_PREFIX}_"); do
    qconf -dp $pe
done

echo "You should have root privs for this next part.  Hope you're in sudoers..."

# Add complex values to queues
for queue in $(qconf -sql); do
    qconf -dattr queue complex_values pcpus=99999 $queue
    qconf -dattr queue complex_values nodes=99999 $queue
    qconf -dattr queue complex_values ppn=99999 $queue
done

# Remove complex attributes
qconf -sc | egrep -v '(pcpus|nodes|ppn)' >> /tmp/complexAttribs.$$
qconf -Mc /tmp/complexAttribs.$$
rm -f  /tmp/complexAttribs.$$

# Remove complex values on queues

exit
