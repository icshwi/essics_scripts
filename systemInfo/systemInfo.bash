#!/bin/bash
#
#  Copyright (c) 2016 - Present European Spallation Source ERIC
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
#   date    : Tuesday, June 13 12:24:48 CEST 2017
#   version : 0.0.2

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME="$(basename "$SC_SCRIPT")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"
declare -gr SC_IOCUSER="$(whoami)"


set -a
. ${SC_TOP}/env.conf
set +a

. ${SC_TOP}/functions


get_kernel_version
get_centos_version
get_css_version
get_java_version
get_system_vendor

print_summary


os_release

printf "\n";


printf "\n";
printf "Hardware Vendor Information :\n";

# Currently, we only need to know system and chassis vendor and ...
sudo /usr/sbin/dmidecode -t system  -t chassis
# Maybe we also need the ethernet port numbers or others..

# sudo /usr/sbin/dmidecode -t system  -t chassis -t baseboard -t processor
