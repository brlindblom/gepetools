#!/bin/bash
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
