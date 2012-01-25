#!/bin/bash
#
# Creates parallel environments that are suitable for use 
# with the gepetools package and hence work universally with
# most MPI implementations
#
# Run with: createpe.sh 1 2 4 8 16 
# where the numeric arguments are the processors-per-node for 
# each pe.
#

shift
ppns=( $@ )

function pe_exists(){
    qconf -spl 2>&1 | grep -q '^mpi$'
    return $?
}

if pe_exists mpi; then
    echo "PE 'mpi' already exists! Bailing..."
    exit 1
fi

cat >/tmp/pefile.$$ <<EOF
pe_name            mpi
slots              9999 
user_lists         NONE
xuser_lists        NONE
start_proc_args    $SGE_ROOT/gepetools/startpe.sh \$pe_hostfile
stop_proc_args     $SGE_ROOT/gepetools/stoppe.sh
allocation_rule    \$round_robin
control_slaves     TRUE
job_is_first_task  FALSE
urgency_slots      min
accounting_summary FALSE
EOF
qconf -Ap /tmp/pefile.$$

for ppn in ${ppns[@]}; do
    pe=mpi.$ppn
   
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
start_proc_args    $SGE_ROOT/gepetools/startpe.sh \$pe_hostfile
stop_proc_args     $SGE_ROOT/gepetools/stoppe.sh
allocation_rule    $ppn
control_slaves     TRUE
job_is_first_task  FALSE
urgency_slots      min
accounting_summary FALSE
EOF
    qconf -Ap /tmp/pefile.$$
fi

rm -f /tmp/pefile.$$
