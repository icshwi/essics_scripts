#!/bin/bash
#
#  Copyright (c) 2016 European Spallation Source ERIC
#  Copyright (c) 2016 Paul Scherrer Institute
#  Copyright (c) 2016 Jeong Han Lee
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
#
# - increase a IRQ thread priority of an input device

# root@:~# chrt -m
# SCHED_OTHER min/max priority    : 0/0
# SCHED_FIFO min/max priority     : 1/99
# SCHED_RR min/max priority       : 1/99
# SCHED_BATCH min/max priority    : 0/0
# SCHED_IDLE min/max priority     : 0/0

# it is better to check the pid of device_name and softIOC by the following commands
# ps -eLo pid,rtprio,cls,pri,cmd | grep FF |grep -e device_name -e softIoc | grep -v grep | sort -n



declare DEVICE="$1";

if [ -z "${DEVICE}" ]; then
	echo "">&2
        echo "usage: $0 <device_name>" >&2
        echo >&2
        echo "  device_name: " >&2
        echo ""
        echo "               pev ">&2
        echo ""
        echo "               enp3s0">&2
        echo ""
        echo >&2
        exit 0
fi



declare NEWIRQPRIO=98;
declare PID=0;
declare PS_RETURN="";
declare IRQPRIO=0;

#
# pid is the first item of ps result, so awk uses $1 in order to get pid in ps command
# ps -eLo rtprio,cls,pid,pri,nice,cmd
# 

PS_RETURN=$(ps -eLo pid,rtprio,cls,pri,cmd | grep FF | grep ${DEVICE});

if [ ! "${PS_RETURN}"  ]; then
    printf "There is no RT process of %s\n" "${DEVICE}";
    exit 0
fi


PID=$(echo $PS_RETURN     | awk '{print $1}');
IRQPRIO=$(echo $PS_RETURN | awk '{print $2}');

printf "\n%s IRQ thread priority : Running:%s  Max:%s\n" "${DEVICE}" "${IRQPRIO}" "${NEWIRQPRIO}";
	
if [ "${PID}xxx" == "xxx" ]; then
    printf "%s IRQ thread not found (OK if not PREEMPT_RT kernel)\n" "${DEVICE}";
else
    printf "\nChanging the %s IRQ thread priority from %s to %s\n" "${DEVICE}" "${IRQPRIO}" "${NEWIRQPRIO}";
    #
    # -f : --fifo : set policy to SCHED_FIFO
    # -p : --pid  : operate on existing given pid
    #
    chrt -f -p ${NEWIRQPRIO} ${PID};
fi

exit
