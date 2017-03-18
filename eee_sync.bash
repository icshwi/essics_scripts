#!/bin/bash
#
#  Copyright (c) 2016 Jeong Han Lee
#  Copyright (c) 2016 European Spallation Source ERIC
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
#   author  : Jeong Han Lee
#   email   : jeonghan.lee@gmail.com
#   date    : Tuesday, January 31 16:50:03 CET 2017
#   version : 0.1.2
#

#   ROOT permission is needed to run this script
#
#
#

# U-boot at IOxOS IFC 1210
#
# The following configuration was replaced with ${IOXOS_SRC_TOP}/uEnv_sd.txt binary file
# It will be located in the first partition in SD card.
# 
# setenv fpgaCE "central.bit"; setenv fpgaIO "io.bit";
# setenv loadIO "fatload mmc 0:1 $loadaddr $fpgaIO;fpga load io $loadaddr;"
# setenv loadCE "fatload mmc 0:1 $loadaddr $fpgaCE;fpga load central $loadaddr;"
# setenv fpgaload "run loadIO; run loadCE;fpga reset 11b01"
# setenv bootfile "uImage.bin"; setenv fdtfile "uImage.dtb";
# mmcinfo; run fpgaload
# run sdboot

# We have to change one important parameter in the configuration of a default
# U-boot of the IOxOS IFC 1210 board
#
# setenv envload 'mmcinfo; if fatload mmc 0:1 $loadaddr uEnv_sd.txt; then source $loadaddr && run sdboot; else false; fi'
# setenv bootdelay 5
# saveenv
#
# then, we can boot it automatically.







declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME="$(basename "$SC_SCRIPT")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"

declare -gr RSYNC_EPICS_LOG="/tmp/rsync-epics.log";

declare TARGET_EPICS=""

function __ini_func() { printf "\n>>>> You are entering in  : %s\n" "${1}"; }
function __end_func() { printf "\n<<<< You are leaving from : %s\n" "${1}"; }

# Generic : Redefine pushd and popd to reduce their output messages
# 
function pushd() { builtin pushd "$@" > /dev/null; }
function popd()  { builtin popd  "$@" > /dev/null; }


function eee_rsync(){
    
    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local epics_top=$1;

    local rsync_server="rsync://owncloud01.esss.lu.se:80";

    local rsync_general_option="--recursive --links --perms --times --timeout 120 --exclude-from  ${SC_TOP}/rsync-excluded-list.txt"

    local rsync_epics_option="${rsync_general_option} --log-file=${RSYNC_EPICS_LOG} ";

    # Add some information before showing actual log information of RSYNC
    # Only valid at the first instalation
    #
    cat > ${RSYNC_EPICS_LOG} <<EOF
Please wait for it, it will show up here soooon......
This screen is updated every 2 seconds, to check the rsync log file
in ${RSYNC_EPICS_LOG}. 

EOF

    rsync ${rsync_epics_option} ${rsync_server}/epics ${epics_top} --chmod=Dugo=rwx,Fuog=rwx

    __end_func ${func_name};
}




if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

TARGET_EPICS=/opt/epics

printf "\n* One should wait for rsync EPICS processe \n  in order to check the ESS EPICS Environment.\n  tail -n 10 -f ${RSYNC_EPICS_LOG}";

eee_rsync ${TARGET_EPICS}


exit
