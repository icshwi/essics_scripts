#!/bin/bash


function unset_ca_addr
{
    unset EPICS_CA_ADDR_LIST
    unset EPICS_CA_AUTO_ADDR_LIST
}

function print_ca_addr
{
    echo "EPICS_CA_ADDR_LIST      : $EPICS_CA_ADDR_LIST"
    echo "EPICS_CA_AUTO_ADDR_LIST : $EPICS_CA_AUTO_ADDR_LIST"
    
}

function set_ca_addr
{
    export EPICS_CA_ADDR_LIST="$1"
    export EPICS_CA_AUTO_ADDR_LIST="$2";
    print_ca_addr
}


unset_ca_addr

print_ca_addr

set_ca_addr "$1" "$2"

caget WAVEGENTRIG:IocStats:SYS_CPU_LOAD

# WORKS
# bash addr_debug.bash "10.4.8.22" "YES"
# bash addr_debug.bash "10.4.8.22" "NO"


# $ bash addr_debug.bash 10.255.255.255"" "NO"
# 10.255.255.255
# NO
# Channel connect timed out: 'WAVEGENTRIG:IocStats:SYS_CPU_LOAD' not found.



# $ bash addr_debug.bash 10.255.255.255"" "YES"
# 10.255.255.255
# YES
# Channel connect timed out: 'WAVEGENTRIG:IocStats:SYS_CPU_LOAD' not found.


# bash addr_debug.bash 10.4.8.255"" "YES"
# 10.4.8.255
# YES
# Channel connect timed out: 'WAVEGENTRIG:IocStats:SYS_CPU_LOAD' not found.


# bash addr_debug.bash 10.4.255.255"" "YES"
# 10.4.255.255
# YES
# Warning: Duplicate EPICS CA Address list entry "10.4.255.255:5064" discarded
