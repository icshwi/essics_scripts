#!/bin/bash

# Wednesday, December 14 12:08:14 CET 2016
# Jeong Han Lee
# jeonghan.lee@gmail.com
#
# root permission is needed to run


declare tdir="temp";
declare tdir1=${tdir}1;
declare tdir2=${tdir}2;


if [ ! $# == 1 ]; then
  echo "Usage: $0 /dev/mmcblk0"
  exit
fi

sdcard=$1

#dd if=/dev/zero of=${sdcard} bs=512 count=1
dd if=/dev/zero of=${sdcard} bs=1024 count=1024
# partition 1 : 512M, fat16, bootable
# partition 2 : total - 512M, linux, non-bootable
sfdisk ${sdcard}  <<EOF
,512,e,*
,,L,-
EOF


mkfs.vfat -F 16 -n "boot" ${sdcard}p1
mkfs.ext2 -L "rootfs" ${sdcard}p2

printf "Syncing.....\n";

sync

#mkdir -p {$tdir1,$tdir2}
mkdir -p $tdir2

#mount ${sdcard}p1 ${tdir1}
mount ${sdcard}p2 ${tdir2}

tar xvf /home/jhlee/Desktop/ifc1210-ess-rootfs-151203.tar -C ${tdir2}

printf "\nExtracted rootfs into the root partition\n";

cp -v /home/jhlee/Desktop/uImage.* ${tdir2}/boot/
cp -v /home/jhlee/Desktop/*.bit ${tdir2}/boot/

printf "Syncing.....\n";
sync

printf "\nUnmount temp1 and temp2\n";

#umount ${tdir1}
umount ${tdir2}


exit
