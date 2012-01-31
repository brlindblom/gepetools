#!/bin/bash
#
# Install script
#

# add our PEs
function pe_exists(){
    qconf -spl 2>&1 | grep -q "^$1\$"
    return $?
}

export installDir=$1
export QUEUE_PREFIX=gepetools

echo "You should have root privs for this.  Hope you're in sudoers..."
sudo mkdir -p $installDir
sudo chmod 755 $installDir
ppns=( 1 2 4 6 8 12 16 )

for queue in $(qconf -sql); do
    if pe_exists ${QUEUE_PREFIX}_{queue}; then
        echo "PE '${QUEUE_PREFIX}_${queue}' already exists! Bailing..."
        exit 1
    fi

    cat >/tmp/pefile.$$ <<EOF
pe_name            ${QUEUE_PREFIX}_${queue}
slots              9999 
user_lists         NONE
xuser_lists        NONE
start_proc_args    %%INSTALL_DIR%%/startpe.sh \$pe_hostfile
stop_proc_args     %%INSTALL_DIR%%/stoppe.sh
allocation_rule    \$round_robin
control_slaves     TRUE
job_is_first_task  FALSE
urgency_slots      min
accounting_summary FALSE
EOF
    sed -i "s|%%INSTALL_DIR%%|$installDir|g" /tmp/pefile.$$ 
    qconf -Ap /tmp/pefile.$$
    qconf -mattr queue pe_list ${QUEUE_PREFIX}_$queue $queue
done

for queue in $(qconf -sql); do
    for ppn in ${ppns[@]}; do
        pe=${QUEUE_PREFIX}_${queue}.${ppn}
   
        if pe_exists $pe; then
            echo "PE '$pe' already exists! Bailing..."
            rm -f /tmp/pefile.$$
            exit 1
        fi

        cat >/tmp/pefile.$$ <<EOF
pe_name            $pe
slots              9999
user_lists         NONE
xuser_lists        NONE
start_proc_args    %%INSTALL_DIR%%/startpe.sh \$pe_hostfile
stop_proc_args     %%INSTALL_DIR%%/stoppe.sh
allocation_rule    $ppn
control_slaves     TRUE
job_is_first_task  FALSE
urgency_slots      min
accounting_summary FALSE
EOF
        sed -i "s|%%INSTALL_DIR%%|$installDir|g" /tmp/pefile.$$ 
        qconf -Ap /tmp/pefile.$$
        qconf -mattr queue pe_list $pe $queue
    done
done

rm -f /tmp/pefile.$$

echo "You should have root privs for this next part.  Hope you're in sudoers..."

sudo install --owner=root --group=root --mode=755 startpe.sh $installDir/
sudo sed -i "s|%%INSTALL_DIR%%|$installDir|g" $installDir/startpe.sh
sudo install --owner=root --group=root --mode=755 stoppe.sh $installDir/
sudo sed -i "s|%%INSTALL_DIR%%|$installDir|g" $installDir/stoppe.sh
sudo install --owner=root --group=root --mode=755 getjidprocinfo $installDir/
sudo sed -i "s|%%INSTALL_DIR%%|$installDir|g" $installDir/getjidprocinfo
sudo install --owner=root --group=root --mode=755 extJobInfo $installDir/
sudo sed -i "s|%%INSTALL_DIR%%|$installDir|g" $installDir/extJobInfo
sudo install --owner=root --group=root --mode=755 mpdboot $installDir/
sudo sed -i "s|%%INSTALL_DIR%%|$installDir|g" $installDir/mpdboot
sudo install --owner=root --group=root --mode=755 rsh $installDir/
sudo install --owner=root --group=root --mode=755 pe.jsv $installDir/
sudo install --owner=root --group=root --mode=644 pe_env_setup $installDir/
sudo sed -i "s|%%INSTALL_DIR%%|$installDir|g" $installDir/pe_env_setup
sudo touch $installDir/.gepetools.install

# Setup MPD daemon
sudo rsync -a mpd $installDir/
pushd $installDir/mpd
sudo ./aimk
popd

# Add complex attributes
qconf -sc >> /tmp/complexAttribs.$$
cat >>/tmp/complexAttribs.$$ <<EOF
pcpus                            pcpus                         INT         <=      YES         NO         0        0
nodes                            nodes                         INT         <=      YES         NO         0        0
ppn                              ppn                           INT         <=      YES         NO         0        0
EOF
qconf -Mc /tmp/complexAttribs.$$
rm -f  /tmp/complexAttribs.$$

# Add complex values to queues
for queue in $(qconf -sql); do
    qconf -mattr queue complex_values pcpus=99999 $queue
    qconf -mattr queue complex_values nodes=99999 $queue
    qconf -mattr queue complex_values ppn=99999 $queue
done

exit
