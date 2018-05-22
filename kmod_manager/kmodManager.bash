#!/bin/bash
#
#  Copyright (c) 2017 - Present  Jeong Han Lee
#  Copyright (c) 2017 - Present  European Spallation Source ERIC
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
# Author : Jeong Han Lee
# email  : jeonghan.lee@gmail.com
# Date   : Friday, August 25 12:32:14 CEST 2017
# version : 0.0.4
#

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"


declare -ag INFO_list=()
declare -i  index=0


set -a
. ${SC_TOP}/env.conf
set +a

. ${SC_TOP}/../functions


function print_info() {
    
    for info in "${INFO_list[@]}"
    do
	printf "%2s: %s\n" "$index" "$info";
	let "index = $index + 1";
    done
}


# arg1 : KMOD NAME
# arg2 : Ethernet Device for EtherCAT

function modprobe_kmod(){
    
    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local kmod_name=${1}

    local ecat_dev=${2}
    
 
    #
    # Update kernel module....manually
    #
    ${SUDO_CMD} depmod --quick
    printf "Removing ${kmod_name} ... \n"

    if [ -z "$ecat_dev" ]; then
	${SUDO_CMD} modprobe -rv ${kmod_name};
	${SUDO_CMD} modprobe -v ${kmod_name};
    else
	local mac_address=$(get_macaddr ${ecat_dev});
	${SUDO_CMD} modprobe -rv ${ECAT_KMOD_GENERIC_NAME};
	${SUDO_CMD} modprobe -rv ${kmod_name};
	${SUDO_CMD} modprobe -v ${kmod_name} main_devices=\"${mac_address}\";
	${SUDO_CMD} modprobe -v ${ECAT_KMOD_GENERIC_NAME};
    fi

    INFO_list+=("$(${SUDO_CMD} modinfo ${kmod_name})");
    INFO_list+=("$(lsmod |grep ${kmod_name})");

    __end_func ${func_name};
}

# arg1 : KMOD NAME
# arg2 : target_rootfs, if exists
function put_autoload_conf(){

    local func_name=${FUNCNAME[*]};  __ini_func ${func_name};
    local kmod_name=${1}
    local target_rootfs=${2}
    local rule=${kmod_name}
    local module_load_dir="${target_rootfs}/etc/modules-load.d";
    local target="${module_load_dir}/${kmod_name}.conf";
    
    local isDir=$(checkIfDir ${module_load_dir})
    if [[ $isDir -eq "$NON_EXIST" ]]; then
	${SUDO_CMD} mkdir -p ${module_load_dir};
    fi
    


    printf "Put the autoload conf : %s in %s to load the %s module at boot time.\n" "${rule}" "${target}" "${kmod_name}";
    printf_tee "$rule" "$target";
    cat_file ${target};
    
    __end_func ${func_name};
}


# arg1 : KMOD NAME
# arg2 : target_rootfs, if exists
function put_udev_rule(){

    local func_name=${FUNCNAME[*]};  __ini_func ${func_name};
    local kmod_name=${1}
    local target_rootfs=${2}
    local udev_rules_dir="${target_rootfs}/etc/udev/rules.d"
    local rule=""
    local target=""
 
    case "$kmod_name" in     
	${MRF_KMOD_NAME})
	    rule="KERNEL==\"uio*\", ATTR{name}==\"mrf-pci\", MODE=\"0666\"";
	    target="${udev_rules_dir}/99-${MRF_KMOD_NAME}ioc2.rules";
	    ;;
	${SIS_KMOD_NAME})
	    rule="KERNEL==\"sis8300-[0-9]*\", NAME=\"%k\", MODE=\"0666\"";
	    target="${udev_rules_dir}/99-${SIS_KMOD_NAME}.rules";
	    ;;
	${ECAT_KMOD_NAME})
	    rule="KERNEL==\"EtherCAT*\", SUBSYSTEM==\"EtherCAT\", MODE=\"0666\"";
	    target="${udev_rules_dir}/99-${ECAT_KMOD_NAME}.rules";
	    ;;
	*)
	    # no rule, but create a dummy file
	    rule=""
	    target="${udev_rules_dir}/99-${kmod_name}.rules";
	    ;;
    esac
  
    printf "Put the udev rule : %s in %s to be accessible via an user.\n" "$rule" "$target";
    printf_tee "$rule" "$target";
    cat_file ${target}
    
#trigger update of udev rules without reboot (William Ledda)
	if [ -f /bin/udevadm ]; then
		echo "Triggering online rules update"
		/bin/udevadm trigger
	else
		echo "No udevadm found. Reboot your system to apply new rules!"
	fi
	    
    __end_func ${func_name};
}

# arg1 : KMOD NAME
# arg2 : target_rootfs, if exists

function put_rules() {
    
    local kmod_name=${1}
    local target_rootfs=${2}
    put_autoload_conf "${kmod_name}" "${target_rootfs}" ;
    put_udev_rule "${kmod_name}" "${target_rootfs}";
    
}

function git_compile(){

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local kmod_name=${1}
    local git_src_name=""
    local git_src_dir=""
    local git_src_url=""
    local git_tag_name=""
    local git_hash=""
    local kmod_src_dir=""
    local git_commands=""
    
 
    case "$kmod_name" in     
	${MRF_KMOD_NAME})
	    git_src_name="${MRF_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    git_src_url="${MRF_GIT_SRC_URL}"
	    git_tag_name="${MRF_GIT_TAG_NAME}"
	    git_hash="${MRF_GIT_HASH}"
	    kmod_src_dir="${git_src_dir}/${MRF_KERNEL_DIR}"
	    git_clone "${git_src_dir}" "${git_src_url}" "${git_src_name}" "${git_tag_name}";
	    pushd ${git_src_dir}
	    git checkout "${GIT_HASH}"
	    popd
	    pushd ${kmod_src_dir}
	    printf "\n\n\n\n"
	    ${SUDO_CMD} make modules modules_install clean
	    popd
	    ;;
	${SIS_KMOD_NAME})
	    git_src_name="${SIS_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    git_src_url="${SIS_GIT_SRC_URL}"
	    git_tag_name="${SIS_GIT_TAG_NAME}"
	    kmod_src_dir="${git_src_dir}/${SIS_KERNEL_DIR}"
	    git_clone "${git_src_dir}" "${git_src_url}" "${git_src_name}" "${git_tag_name}";
	    pushd ${kmod_src_dir}
	    printf "\n\n\n\n"
	    ${SUDO_CMD} make modules modules_install clean
	    popd
	    ;;
	# TSC triggers PON and SFLASE also. 
	${TOSCA_TSC_KMOD_NAME})
	    git_src_name="${TOSCA_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    git_src_url="${TOSCA_GIT_SRC_URL}"
	    git_tag_name="${TOSCA_GIT_TAG_NAME}"
	    kmod_src_dir="${git_src_dir}/${TOSCA_TSC_KERNEL_DIR}"
	    git_clone "${git_src_dir}" "${git_src_url}" "${git_src_name}" "${git_tag_name}";
	    pushd ${kmod_src_dir}
	    printf "\n\n\n\n"
	    ${SUDO_CMD} make modules modules_install clean
	    popd
	    kmod_src_dir="${git_src_dir}/${TOSCA_SFL_KERNEL_DIR}"
	    pushd ${kmod_src_dir}
	    printf "\n\n\n\n"
	    ${SUDO_CMD} make modules modules_install clean
	    popd
	    ;;
	${ECAT_KMOD_NAME})
	    git_src_url="${ECAT_GIT_SRC_URL}"
	    git_src_name="${ECAT_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    git_tag_name="${ECAT_GIT_TAG_NAME}"
	    kmod_src_dir="${git_src_dir}/${ECAT_KERNEL_DIR}"
	    git_clone "${git_src_dir}" "${git_src_url}" "${git_src_name}" "${git_tag_name}";
	    echo ${kmod_src_dir}
	    pushd ${kmod_src_dir}
	    autoreconf --force --install -v
	    ./configure --disable-8139too --enable-generic
	    printf "\n\n\n\n"
	    ${SUDO_CMD} make modules modules_install clean
	    popd
	    ;;
	*)
	    printf "Don't support! \n";
	    ;;
    esac

    __end_func ${func_name};
}



function git_cross_compile(){

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local kmod_name=${1}
    local git_src_name=""
    local git_src_dir=""
    local kmod_src_dir=""
    local kerneldir="${IFC1410_KERNELDIR}"
 
    case "$kmod_name" in     
	${MRF_KMOD_NAME})
	    git_src_name="${MRF_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    git_src_url="${MRF_GIT_SRC_URL}"
	    git_tag_name="${MRF_GIT_TAG_NAME}"
	    git_hash="${MRF_GIT_HASH}"
	    kmod_src_dir="${git_src_dir}/${MRF_KERNEL_DIR}"
	    git_clone "${git_src_dir}" "${git_src_url}" "${git_src_name}" "${git_tag_name}";
	    pushd ${git_src_dir}
	    git checkout "${GIT_HASH}"
	    popd
	    pushd ${kmod_src_dir}
	    ${SUDO_CMD} make ARCH=${arch} CROSS_COMPILE=${cc} KERNELDIR=${kerneldir} INSTALL_MOD_PATH=${install_mod_path} modules modules_install clean
	    popd
	    ;;
	${SIS_KMOD_NAME})
	    git_src_name="${SIS_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    git_src_url="${SIS_GIT_SRC_URL}"
	    git_tag_name="${SIS_GIT_TAG_NAME}"
	    kmod_src_dir="${git_src_dir}/${SIS_KERNEL_DIR}"
	    git_clone "${git_src_dir}" "${git_src_url}" "${git_src_name}" "${git_tag_name}";
	    pushd ${kmod_src_dir}
	    ${SUDO_CMD} make ARCH=${arch} CROSS_COMPILE=${cc} KERNELDIR=${kerneldir} INSTALL_MOD_PATH=${install_mod_path} modules modules_install clean
	    popd
	    ;;
	# TSC triggers PON and SFLASE also. 
	${TOSCA_TSC_KMOD_NAME})
	    git_src_name="${TOSCA_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    git_src_url="${TOSCA_GIT_SRC_URL}"
	    git_tag_name="${TOSCA_GIT_TAG_NAME}"
	    kmod_src_dir="${git_src_dir}/${TOSCA_TSC_KERNEL_DIR}"
	    git_clone "${git_src_dir}" "${git_src_url}" "${git_src_name}" "${git_tag_name}";
	    pushd ${kmod_src_dir}
	    ${SUDO_CMD} make ARCH=${arch} CROSS_COMPILE=${cc} KERNELDIR=${kerneldir} INSTALL_MOD_PATH=${install_mod_path} modules modules_install clean
	    popd
	    kmod_src_dir="${git_src_dir}/${TOSCA_SFL_KERNEL_DIR}"
	    pushd ${kmod_src_dir}
	    ${SUDO_CMD} make ARCH=${arch} CROSS_COMPILE=${cc} KERNELDIR=${kerneldir} INSTALL_MOD_PATH=${install_mod_path} modules modules_install clean
	    popd
	    ;;
	*)
	    printf "Don't support. Exiting...\n";
	    ;;
    esac

    __end_func ${func_name};
}




function git_clone_for_ifc1410(){

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local kmod_name=${1}
    local git_src_name=""
    local git_src_dir=""
    local git_src_url=""
    local git_tag_name=""
    local git_hash=""
    local kmod_src_dir=""
    local git_commands=""
    
 
    case "$kmod_name" in     
	${MRF_KMOD_NAME})
	    git_src_name="${MRF_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    git_src_url="${MRF_GIT_SRC_URL}"
	    git_tag_name="${MRF_GIT_TAG_NAME}"
	    git_hash="${MRF_GIT_HASH}"
	    kmod_src_dir="${git_src_dir}/${MRF_KERNEL_DIR}"
	    git_clone "${git_src_dir}" "${git_src_url}" "${git_src_name}" "${git_tag_name}";
	    pushd ${git_src_dir}
	    git checkout "${GIT_HASH}"
	    popd
	    ;;
	${SIS_KMOD_NAME})
	    git_src_name="${SIS_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    git_src_url="${SIS_GIT_SRC_URL}"
	    git_tag_name="${SIS_GIT_TAG_NAME}"
	    kmod_src_dir="${git_src_dir}/${SIS_KERNEL_DIR}"
	    git_clone "${git_src_dir}" "${git_src_url}" "${git_src_name}" "${git_tag_name}";
	    ;;
	# TSC triggers PON and SFLASE also. 
	${TOSCA_TSC_KMOD_NAME})
	    git_src_name="${TOSCA_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    git_src_url="${TOSCA_GIT_SRC_URL}"
	    git_tag_name="${TOSCA_GIT_TAG_NAME}"
	    kmod_src_dir="${git_src_dir}/${TOSCA_TSC_KERNEL_DIR}"
	    git_clone "${git_src_dir}" "${git_src_url}" "${git_src_name}" "${git_tag_name}";
	    ;;
	*)
	    printf "Don't support! \n";
	    ;;
    esac

    __end_func ${func_name};
}



function git_clean_for_ifc1410(){

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local kmod_name=${1}
    local git_src_name=""
    local git_src_dir=""
    local git_src_url=""
    local git_tag_name=""
    local git_hash=""
    local kmod_src_dir=""
    local git_commands=""
    
 
    case "$kmod_name" in     
	${MRF_KMOD_NAME})
	    git_src_name="${MRF_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    ;;
	${SIS_KMOD_NAME})
	    git_src_name="${SIS_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    ;;
	# TSC triggers PON and SFLASE also. 
	${TOSCA_TSC_KMOD_NAME})
	    git_src_name="${TOSCA_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    ;;
	*)
	    printf "Don't support! \n";
	    ;;
    esac

    # make a backup dir at least, so overwrite them again and again
    # mv ${git_src_dir} ${git_src_dir}_bak
    printf "Removing %s .....\n" "${git_src_dir}"
    rm -rf ${git_src_dir}

    __end_func ${func_name};
}





# arg1 : KMOD NAME
# git sources should be downloaded in the host, be copied to rootfs under this
# repositries. 
function git_compile_on_ifc1410(){

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local kmod_name=${1}
    local git_src_name=""
    local git_src_dir=""
    local kmod_src_dir=""
    local kerneldir="${IFC1410_KERNELDIR}"
 
    case "$kmod_name" in     
	${MRF_KMOD_NAME})
	    git_src_name="${MRF_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    kmod_src_dir="${git_src_dir}/${MRF_KERNEL_DIR}"
	    pushd ${kmod_src_dir}
	    ${SUDO_CMD} make KERNELDIR=${kerneldir} modules modules_install clean
	    popd
	    ;;
	${SIS_KMOD_NAME})
	    git_src_name="${SIS_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    ${SUDO_CMD} make KERNELDIR=${kerneldir} modules modules_install clean
	    popd
	    ;;
	# TSC triggers PON and SFLASH also. 
	${TOSCA_TSC_KMOD_NAME})
	    git_src_name="${TOSCA_GIT_SRC_NAME}"
	    git_src_dir="${SC_TOP}/${git_src_name}"
	    kmod_src_dir="${git_src_dir}/${TOSCA_TSC_KERNEL_DIR}"
	    pushd ${kmod_src_dir}
	    ${SUDO_CMD} make KERNELDIR=${kerneldir} modules modules_install clean
	    popd
	    kmod_src_dir="${git_src_dir}/${TOSCA_SFL_KERNEL_DIR}"
	    pushd ${kmod_src_dir}
	    ${SUDO_CMD} make KERNELDIR=${kerneldir}  modules modules_install clean
	    popd
	    ;;
	*)
	    printf "Don't support. Exiting...\n";
	    ;;
    esac

    __end_func ${func_name};
}

function modules_prepare() {
    
    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    pushd ${IFC1410_KERNELDIR}
    make ${TARGET_KERNEL_DEFCONFIG} modules_prepare
    popd
    
    __end_func ${func_name};
}


function show_pci_devices_per_a_vendor () {
    local vendor_id=$1
    printf "\nWe is looking for the boards with the vendor id %s as follows:" "${vendor_id}";
    printf "\n--------------------------------------\n";
    lspci -nmmn | grep -E "\<(${vendor_id})";
    printf "\n";
}


function install_kmodManager_on_ifc1410() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local target_rootfs_home=${TARGET_ROOTFS}/home/root/ics_gitsrc
    local rep_name=${REPO_NAME}

#	echo ${target_rootfs_home}/${rep_name}    
    printf ".... Removing the existent %s\n\n" "${target_rootfs_home}/${rep_name}"
    ${SUDO_CMD} rm -rf ${target_rootfs_home}/${rep_name}
    printf ".... Installing %s to %s\n\n" "${rep_name}" "${target_rootfs_home}"
    ${SUDO_CMD} scp -rv ${SC_TOP}/../../${rep_name} ${target_rootfs_home}
    
    __end_func ${func_name};
}


function git_src_all() {
    git_clone_for_ifc1410 ${MRF_KMOD_NAME}
    git_clone_for_ifc1410 ${TOSCA_TSC_KMOD_NAME}
    #       git_clone_for_ifc1410 ${SIS_KMOD_NAME}
}

function git_clr_all() {
    git_clean_for_ifc1410 ${MRF_KMOD_NAME}
    git_clean_for_ifc1410 ${TOSCA_TSC_KMOD_NAME}
    #       git_clean_for_ifc1410 ${SIS_KMOD_NAME}
}

INFO_list+=("SCRPIT      : ${SC_SCRIPT}");
INFO_list+=("SCRIPT NAME : ${SC_SCRIPTNAME}");
INFO_list+=("SCRIPT TOP  : ${SC_TOP}");
INFO_list+=("LOGDATE     : ${SC_DATE}");

DO="$1"
ECAT_MASTER_DEV="$2"



case "$DO" in     
    mrf)
	git_compile   ${MRF_KMOD_NAME};
	modprobe_kmod ${MRF_KMOD_NAME};
	put_rules     ${MRF_KMOD_NAME};
	print_info ;
	;;
    mrf_cc)
	git_cross_compile ${MRF_KMOD_NAME};
	modprobe_kmod ${MRF_KMOD_NAME};
	put_rules ${MRF_KMOD_NAME} ${TARGET_ROOTFS};
	print_info ;
	;;
    mrf_ifc1410)
	git_compile_on_ifc1410 ${MRF_KMOD_NAME};
	modprobe_kmod ${MRF_KMOD_NAME};
	put_rules ${MRF_KMOD_NAME};
	print_info ;
	;;
    sis)
	git_compile   ${SIS_KMOD_NAME};
	modprobe_kmod ${SIS_KMOD_NAME};
	put_rules     ${SIS_KMOD_NAME};
	print_info ;
	;;
    sis_cc)
	git_cross_compile ${SIS_KMOD_NAME};
	modprobe_kmod ${SIS_KMOD_NAME};
	put_rules ${SIS_KMOD_NAME} ${TARGET_ROOTFS};
	print_info ;
	;;
    sis_ifc1410)
	git_compile_on_ifc1410 ${SIS_KMOD_NAME};
	modprobe_kmod ${SIS_KMOD_NAME};
	put_rules ${SIS_KMOD_NAME};
	print_info ;
	;;
    tsc)
	git_compile   ${TOSCA_TSC_KMOD_NAME};
	modprobe_kmod ${TOSCA_TSC_KMOD_NAME};
	put_rules     ${TOSCA_TSC_KMOD_NAME};
	modprobe_kmod ${TOSCA_SFL_KMOD_NAME};
	put_rules     ${TOSCA_SFL_KMOD_NAME};
	print_info ;
	;;
    tsc_cc)
	git_cross_compile ${TOSCA_TSC_KMOD_NAME};
	modprobe_kmod ${TOSCA_TSC_KMOD_NAME};
	put_rules ${TOSCA_TSC_KMOD_NAME} ${TARGET_ROOTFS};
	modprobe_kmod ${TOSCA_SFL_KMOD_NAME};
	put_rules ${TOSCA_SFL_KMOD_NAME} ${TARGET_ROOTFS};
	print_info ;
	;;
    tsc_ifc1410)
	git_compile_on_ifc1410 ${TOSCA_TSC_KMOD_NAME};
	modprobe_kmod ${TOSCA_TSC_KMOD_NAME};
	put_rules     ${TOSCA_TSC_KMOD_NAME};
        modprobe_kmod ${TOSCA_PON_KMOD_NAME};
        put_rules     ${TOSCA_PON_KMOD_NAME};
	modprobe_kmod ${TOSCA_SFL_KMOD_NAME};
	put_rules     ${TOSCA_SFL_KMOD_NAME};
	print_info ;
	;;
    ecat)
	if [ -z "$ECAT_MASTER_DEV" ]; then
	    
	    echo "Please define the ethernet device name"

	else
	    git_compile   ${ECAT_KMOD_NAME};
	    modprobe_kmod ${ECAT_KMOD_MASTER_NAME}  ${ECAT_MASTER_DEV} ; 
	    put_rules     ${ECAT_KMOD_NAME};
	    print_info ;
	fi
	;; 
    show)
	show_pci_devices_per_a_vendor ${PCI_VENDOR_ID_MRF}
	show_pci_devices_per_a_vendor ${PCI_VENDOR_ID_SIS}
	show_pci_devices_per_a_vendor ${PCI_VENDOR_ID_IOX}
	;;
    mod_prepare)
	modules_prepare
	;;
    git_src)
	git_clr_all
	git_src_all
	;;
    git_clr)
	git_clr_all
	;;
    install_me)
	install_kmodManager_on_ifc1410
	;;
    ntpdate)
	ntpdate 10.0.7.53 
	;;
    *) 	
	echo "">&2         
	echo "usage: $0 <arg>">&2 
	echo "">&2
        echo "          <arg>        :  info">&2 
	echo "">&2
	echo "          git_src      :  Download sources locally. ">&2
	echo "          git_clr      :  Remove   local souce dirs. ">&2
	echo "          install_me   :  Install ${REPO_NAME} into ${TARGET_ROOTFS}. ">&2
        echo "          ntpdate      :  time sync with host">&2
	echo "">&2
	echo "          show         :  Show the found boards information ">&2
	echo "">&2
	echo "          mod_prepare  :  One time, if the fresh rootfs is used. ">&2

	echo "">&2
	echo "          mrf          :  OK ">&2
	echo "          mrf_cc       :  NOT tested">&2
	echo "          mrf_ifc1410  :  OK ">&2
	echo "">&2
	echo "          tsc          :  NOK ">&2
	echo "          tsc_cc       :  NOT tested">&2
	echo "          tsc_ifc1410  :  OK  : COMPILE / kmod autoload conf">&2
	echo "                       :      : no use udev">&2
	echo "                       :  NOK : modprobe ">&2
	echo "">&2
	echo "          ecat  netdev :  OK ">&2
	echo "    (ex.) ecat  eth0   :     ">&2
        echo "">&2
	echo "          sis          :  OK ">&2
	echo "          sis_cc       :  NOT tested">&2
	echo "          sis_ifc1410  :  NOK - shoud replace makefile">&2
    	echo "">&2 	
	exit 0         
	;; 
esac


exit
