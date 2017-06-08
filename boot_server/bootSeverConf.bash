#!/bin/bash
#
#  Copyright (c) 2017 - Present European Spallation Source ERIC
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
# email  : han.lee@esss.se
# Date   : Thursday, June  8 09:40:43 CEST 2017
# version : 0.0.2




declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%m%d-%H%M)"
declare -gr SUDO_CMD="sudo"



. ${SC_TOP}/../functions




#
# Enable and Start an input Service
# 
# Even if the service is active (running), it is OK to run "enable and start" again. 
# systemctl can accept many services with one command

function __system_ctl_enable_start(){
    
    local func_name=${FUNCNAME[*]};  __ini_func ${func_name};
    __checkstr ${SUDO_CMD}; __checkstr ${1};

    printf "Enable and Start the following service(s) : %s\n" "${1}";
    
    ${SUDO_CMD} systemctl enable ${1};
    ${SUDO_CMD} systemctl start ${1};

    __end_func ${func_name};
}

function __system_ctl_stop_disable(){
    
    local func_name=${FUNCNAME[*]};  __ini_func ${func_name};

    printf "Stop and Disable the following service(s) : %s\n" "${1}";

    ${SUDO_CMD} systemctl stop ${1};
    ${SUDO_CMD} systemctl disable ${1};

    __end_func ${func_name};
}

#  Stop and disable packagekit and firewalld services
#  Remove packagekit
#  Disable SELINUX (reboot is needed)
#  Install minimal packages

function preparation_centos() {
    
    local func_name=${FUNCNAME[*]};  __ini_func ${func_name};
    __checkstr ${SUDO_CMD};

    __system_ctl_stop_disable "packagekit"
    __system_ctl_stop_disable "firewalld"
    __system_ctl_stop_disable "iptables"
    
    declare -r yum_pid="/var/run/yum.pid"
    
    # Somehow, yum is running due to PackageKit, so if so, kill it
    #
    if [[ -e ${yum_pid} ]]; then
	${SUDO_CMD} kill -9 $(cat ${yum_pid})
	if [ $? -ne 0 ]; then
	    printf "Remove the orphan yum pid\n";
	    ${SUDO_CMD} rm -rf ${yum_pid}
	fi
    fi
    
    # Remove PackageKit
    #
    ${SUDO_CMD} yum -y remove PackageKit firewalld;

    local selinux_status=$(/usr/sbin/getenforce)
    local isVar=""
    isVar=$(compare_strs "$selinux_status" "Enforcing")
    if [[ $isVar -eq "$EXIST" ]]; then
	
	local selinux_conf="/etc/sysconfig/selinux"
	${SUDO_CMD} sed -i~ 's/^SELINUX=.*/SELINUX=disabled/g' ${selinux_conf}
    fi
    declare -a package_list=();

    package_list+="tftp-server tftp"
    package_list+=" ";
    package_list+="screen xterm xorg-x11-fonts-misc";
    package_list+=" ";
    package_list+="nfs-utils"
    package_list+=" ";
    package_list+="kernel-headers kernel-devel"
    package_list+=" ";
    
    ${SUDO_CMD} yum -y install ${package_list};


    if [[ $isVar -eq "$EXIST" ]]; then
	echo "Please reboot your system!"
    fi
   
    __end_func ${func_name};
}



# not working, but a place holder for...

# install package
function preparation_debian() {
    
    local func_name=${FUNCNAME[*]};  __ini_func ${func_name};
 
    # __system_ctl_stop_disable "packagekit"
    __system_ctl_stop_disable "firewalld"
    
    # declare -r yum_pid="/var/run/yum.pid"

    # # Somehow, yum is running due to PackageKit, so if so, kill it
    # #
    # if [[ -e ${yum_pid} ]]; then
    # 	${SUDO_CMD} kill -9 $(cat ${yum_pid})
    # 	if [ $? -ne 0 ]; then
    # 	    printf "Remove the orphan yum pid\n";
    # 	    ${SUDO_CMD} rm -rf ${yum_pid}
    # 	fi
    # fi
    
    # # Remove PackageKit
    # #
    # ${SUDO_CMD} yum -y remove PackageKit ;


    declare -a package_list=();

    package_list+="tftp-server tftp"
    package_list+=" ";
    package_list+="screen xterm xorg-x11-fonts-misc";
    package_list+=" ";
    package_list+="nfs-utils"
    package_list+=" ";
    package_list+="kernel-devel"
    package_list+=" ";

    ${SUDO_CMD} apt-get -y install ${package_list};
    
    __end_func ${func_name};
}


function tftp_server_conf(){

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local tftp_conf_path="/etc/xinetd.d"
    local systemd_conf_path="/etc/systemd/system/"

    ${SUDO_CMD} install -m 644 ${SC_TOP}/tftp         ${tftp_conf_path}
    ${SUDO_CMD} install -m 644 ${SC_TOP}/tftp.socket  ${systemd_conf_path}
    ${SUDO_CMD} install -m 644 ${SC_TOP}/tftp.service ${systemd_conf_path}

    __system_ctl_enable_start "tftp.socket"
    __system_ctl_enable_start "tftp"
    
    # TFTP uses 69 port
    # https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-7
    #${SUDO_CMD} iptables -I INPUT -p udp --dport 69 -j ACCEPT

    # ${SUDO_CMD} firewall-cmd --zone=public --permanent --add-service=tftp;
    # ${SUDO_CMD} firewall-cmd --reload;
    
    __end_func ${func_name};
}


function nfs_server_conf() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local exports_path="/etc/"

    ## The following lines should be replaced with 
    local pkg_tgz_path="${HOME}/serverpkgs/"
  
    ${SUDO_CMD} tar xvzf ${pkg_tgz_path}/boot.tgz -C /export/
    ${SUDO_CMD} tar xvzf ${pkg_tgz_path}/images.tgz -C /export/
    ${SUDO_CMD} tar xvzf ${pkg_tgz_path}/nfsroot.tgz -C /export/
    
    
    ${SUDO_CMD} install -m 644 ${SC_TOP}/exports   ${exports_path}
    
    ${SUDO_CMD} systemctl restart nfs

    __end_func ${func_name};
}


function toolchain_conf() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    local toolchain_name="fsl-qoriq_1.9.tgz"
    
    ## The following lines should be replaced with 
    local pkg_tgz_path="${HOME}/serverpkgs/"
    
    ${SUDO_CMD} tar xvzf ${pkg_tgz_path}/${toolchain_name} -C /opt/

    __end_func ${func_name};
}



# couldn't find a way to compile the uboot-tools
# install uboot-tools-2001.03-1.el6.x86_64.rpm by hand
# 

function uboot_tools_conf () {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    
    # http:// should have the / after domain
    # git:.// should not have the / after domain
    
    local git_src_url="git://git.denx.de"
    local git_src_name="u-boot.git"
    local git_src_dir=${SC_TOP}/${git_src_name};
    local git_src_tag="v2017.03";
    
    printf "\n>>>"
    printf "\n>>> Now, we are going to clone and build %s \n" "${git_src_name}"
    

    git_clone  "${git_src_dir}" "${git_src_url}" "${git_src_name}" "${git_src_tag}";
    
    # pushd ${git_src_dir};
    # ls
    # popd

    # pushd ${git_src_dir}/unix;
    # make -f Makefile.gtk
    # #
    # # mv only putty binary to /usr/local/bin directory manually.
    # # and overwrite an existing file

    # printf "\n>>>"
    # printf "\n>>> Now, we are moving the putty to /usr/local/bin manually\n"
    # ${SUDO_CMD} mv --force putty /usr/local/bin/ 
    # popd

    __end_func ${func_name};
}



case "$1" in
    prepare)
	preparation_centos;
	;;
    tftp)
	tftp_server_conf;
	;;
    nfs)
	nfs_server_conf;
	;;
    toolchain)
	toolchain_conf;
	;;
    # uboot)
    # 	uboot_tools_conf;
    # 	;;
    all)
	preparation_centos;
	tftp_server_conf;
	nfs_server_conf;
	toolchain_conf;
	;;
    
    *)

	echo "">&2
        echo " BootServer Configurator  ">&2
	echo ""
	echo " Usage: $0 <arg>">&2 
	echo ""
        echo "          <arg>               : info">&2 
	echo ""
	echo "          prepare     :  << ">&2
	echo "          tftp        :  << ">&2
	echo "          nfs         :  << ">&2
	echo "          toolchain   :  << ">&2
	echo "          all         :  << ">&2
	echo "">&2 	
	exit 0
esac





