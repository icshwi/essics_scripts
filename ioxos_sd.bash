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
#   version : 0.1.1
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

declare TEMP_TARGET_TOP="temp";
declare TEMP_TARGET_TOP1=${TEMP_TARGET_TOP}1;
declare TEMP_TARGET_TOP2=${TEMP_TARGET_TOP}2;
declare IOXOS_SRC_TOP="ioxos_images"
declare -gr RSYNC_EPICS_LOG="/tmp/rsync-epics.log";

declare TARGET_BITFILE=""
declare TARGET_BOOT=""
declare TARGET_EPICS=""
# fstab : rw permissoin
# sudo  : chmod +rw permissions 
declare IOXOS_ROOTFS="ifc1210-ess-rootfs-151203rw.tgz"
# device /dev/sdX, p=""
# device /dev/mmcblk0, p="p"

declare p=""


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


function home_setup() {
    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local root_home=${TEMP_TARGET_TOP2}/home/root
    # temp, solution, we need to change /etc/fstab file as rw
    chmod -R +w ${root_home}
    pushd ${root_home}
    git clone https://github.com/jeonghanlee/essics_scripts
    git clone https://github.com/jeonghanlee/icsem_scripts
    popd
    # add the RW fstab in the gz image
    # cp -R ${SC_TOP}/fstab ${TEMP_TARGET_TOP2}/etc/
 
    __end_func ${func_name};
}
	

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi


if [ ! $# == 1 ]; then
  echo "Usage: $0 /dev/mmcblk0"
  exit
fi

sdcard=$1
substring="mmc";

if test "${sdcard#*$substring}" != "$sdcard"; then
    p="p";
else
    p="";
fi

sdcard_part1=${sdcard}${p}1
sdcard_part2=${sdcard}${p}2

# Mostly, we will see the following message:
# umount: /dev/sdh1: not mounted

umount ${sdcard_part1}
umount ${sdcard_part2}

#dd if=/dev/zero of=${sdcard} bs=512 count=1

dd if=/dev/zero of=${sdcard} bs=512 count=1

# partition 1 : 512M, fat16, bootable
# partition 2 : total - 512M, linux, non-bootable
sfdisk ${sdcard}  <<EOF
,512,e,*
,,L,-
EOF

# Format the first partition on as VFAT 16 as boot
# We don't use this partion, but may use it later as a uboot holder
#
# fat16 and ext2 are the same as the IOxOS setup
#

printf "Formating ...\n";

mkfs.vfat -F 16 -n "boot" ${sdcard_part1}
mkfs.ext2 -L "rootfs" ${sdcard_part2}

printf "Syncing.....\n";

sync



# Mount a second partition, and copy all necessary files into
# rootfs, uImage.bin, uImage.dtb, some FPGA bit files
# the source should be defined in IOXOS_SRC_TOP
# Later, we can download them from ESS repository...I hope

mkdir -p {$TEMP_TARGET_TOP1,$TEMP_TARGET_TOP2}
#mkdir -p $TEMP_TARGET_TOP2

mount ${sdcard_part1} ${TEMP_TARGET_TOP1}
mount ${sdcard_part2} ${TEMP_TARGET_TOP2}


printf "Extracting rootfs into %s ... \n" "${TEMP_TARGET_TOP2}";

tar zxf ${IOXOS_SRC_TOP}/${IOXOS_ROOTFS} -C ${TEMP_TARGET_TOP2}



TARGET_BITFILE=${TEMP_TARGET_TOP1}/
TARGET_BOOT=${TEMP_TARGET_TOP2}/boot
TARGET_EPICS=${TEMP_TARGET_TOP2}/opt/epics
TARGET_SYSTEMD=${TEMP_TARGET_TOP2}/lib/systemd/system/
SRC_SYSTEMD=${SC_TOP}/ioxos_sd_fs/pevautostart.service

cp -v ${IOXOS_SRC_TOP}/*.bit       ${TARGET_BITFILE}
cp -v ${IOXOS_SRC_TOP}/uEnv_sd.txt ${TARGET_BITFILE}
cp -v ${IOXOS_SRC_TOP}/uImage.*    ${TARGET_BOOT}
cp -v ${SRC_SYSTEMD} ${TARGET_SYSTEMD}
    

printf "\n* One should wait for rsync EPICS processe \n  in order to check the ESS EPICS Environment.\n  tail -n 10 -f ${RSYNC_EPICS_LOG}";

eee_rsync ${TARGET_EPICS}

printf "\n Home Setup .....\n";

home_setup

printf "Syncing.....\n";
sync
sync
printf "End Sync... \n";

printf "\nUmount %s ....\n" "${TEMP_TARGET_TOP2}";
printf "Umount %s .... \n" "${TEMP_TARGET_TOP1}";

umount ${TEMP_TARGET_TOP2}

umount ${TEMP_TARGET_TOP1}

exit
