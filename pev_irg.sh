#!/bin/bash
# increase PEV IRQ thread priority
# this has to be executed after PEV driver has been loaded
# find the PID of pev irq handler thread and increase it's priority above highest EPICS thread with 'chrt' command

# root@IFC1210_101:~# chrt -m
# SCHED_OTHER min/max priority    : 0/0
# SCHED_FIFO min/max priority     : 1/99
# SCHED_RR min/max priority       : 1/99
# SCHED_BATCH min/max priority    : 0/0
# SCHED_IDLE min/max priority     : 0/0

set -efo pipefail

declare -gr  DEVICE="pev";
declare -gr  NEWPEVIRQPRIO=98;
declare -gi  PEVPID=0;
declare -g   PS_RETURN="";
declare -gi  PEVIRQPRIO=0;

#
# pid is the first item of ps result, so awk uses $1 in order to get pid in ps command
#ps -eLo rtprio,cls,pid,pri,nice,cmd
PS_RETURN=$(ps -eLo pid,rtprio,cls,pri,cmd | grep FF | grep ${DEVICE});

PEVPID=$(echo $PS_RETURN     | awk '{print $1}');
PEVIRQPRIO=$(echo $PS_RETURN | awk '{print $2}');

printf "\nPEV IRQ thread priority : Running:%s  Max:%s\n" "${PEVIRQPRIO}" "${NEWPEVIRQPRIO}";
	
if [ "${PEVPID}xxx" == "xxx" ]; then
    printf "PEV IRQ thread not found (OK if not PREEMPT_RT kernel)\n";
else
    printf "\nIncreasing PEV IRQ thread priority from %s to %s\n" "${PEVIRQPRIO}" "${NEWPEVIRQPRIO}";
    #
    # -f : --fifo : set policy to SCHED_FIFO
    # -p : --pid  : operate on existing given pid
    #
    chrt -f -p ${NEWPEVIRQPRIO} -p ${PEVPID};
fi
    
exit
