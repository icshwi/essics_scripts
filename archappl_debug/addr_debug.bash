#!/bin/bash


function unset_ca_addr
{
    printf "Unset .... \n"
    unset EPICS_CA_ADDR_LIST
    unset EPICS_CA_AUTO_ADDR_LIST
    printf "\n";
}

function print_ca_addr
{
    printf "\n"
    echo "EPICS_CA_ADDR_LIST      : $EPICS_CA_ADDR_LIST"
    echo "EPICS_CA_AUTO_ADDR_LIST : $EPICS_CA_AUTO_ADDR_LIST"
    printf "\n";
}

function set_ca_addr
{
    printf "Set ... \n";
    export EPICS_CA_ADDR_LIST="$1"
    export EPICS_CA_AUTO_ADDR_LIST="$2";
    print_ca_addr
}

function caget_ft
{
    caget "$1"
}

APV="WAVEGENTRIG:IocStats:SYS_CPU_LOAD"


unset_ca_addr
set_ca_addr "$1" "NO"
caget_ft $APV

unset_ca_addr
set_ca_addr "$1" "YES"
caget_ft $APV


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
