#!/bin/bash
#
#  Copyright (c) 2016 - Present Jeong Han Lee
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
# Author : Jeong Han Lee
# email  : han.lee@esss.se
# Date   : Monday, August 28 13:58:37 CEST 2017
# version : 0.0.4
#

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME="$(basename "$SC_SCRIPT")"
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"
declare -gr SC_LOGDATE="$(date +%Y%b%d-%H%M-%S%Z)"

declare hostname_cmd="$(hostname)"

export  _HOST_NAME="$(tr -d ' ' <<< $hostname_cmd )"
export  _HOST_IP="$(ping -n  -c 1 ${_HOST_NAME} | awk 'BEGIN {FS="[=]|[ ]"} NR==2 {print $4}' | cut -d: -f1)";
export  _USER_NAME="$(whoami)"


function pushd() { builtin pushd "$@" > /dev/null; }
function popd()  { builtin popd  "$@" > /dev/null; }

function __ini_func() { printf "\n>>>> You are entering in  : %s\n" "${1}"; }
function __end_func() { printf "\n<<<< You are leaving from : %s\n" "${1}"; }

function __checkstr() {
    if [ -z "$1" ]; then
	printf "%s : input variable is not defined \n" "${FUNCNAME[*]}"
	exit 1;
    fi
}

function download_css() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local css_url="https://artifactory01.esss.lu.se/artifactory/CS-Studio/${CSS_TYPE}/${CSS_VERSION}";
    local css_filename="cs-studio-ess-${CSS_VERSION}-linux.gtk.x86_64.tar.gz";

    $wget_command ${css_url}/${css_filename} 

    ${SUDO_CMD} -v

    if [[ -L ${CSS_DIR} && -d ${CSS_DIR} ]]
    then
	printf "%s is a symlink to a directory, so removing it.\n" "${CSS_DIR}";
	${SUDO_CMD} rm ${CSS_DIR}
    fi

    if [[ -d ${CSS_DIR} ]]
    then
	printf "$s is the physical directory, it should NOT be." "${CSS_DIR}";
	printf "Please check it, and the old %s is renamed to %s\n" "${CSS_DIR}" "${CSS_DIR}-PLEASECHECK-${SC_LOGDATE}"
	${SUDO_CMD} mv ${CSS_DIR} ${CSS_DIR}-PLEASECHECK-${SC_LOGDATE}
    fi

    # Extract css into ${CSS_TOP}, so it has the following name : cs-studio
    ${SUDO_CMD} $tar_command ${css_filename}  -C ${CSS_TOP}
    # Rename to 
    ${SUDO_CMD} mv ${CSS_GENERIC_DIR} ${CSS_DEPLOY_DIR}
    # Create a symlink ${CSS_DIR} 
    ${SUDO_CMD} ln -s ${CSS_DEPLOY_DIR} ${CSS_DIR}
    
    local css_hack_shell="css"

    cat > ${css_hack_shell} <<EOF
#!/bin/sh
#  Generated at  ${SC_LOGDATE}     
#            on  ${_HOST_NAME}  
#                ${_HOST_IP}
#            by  ${_USER_NAME}
#                ${SC_TOP}/${SC_SCRIPTNAME}
#
#  Jeong Han Lee, han.lee@esss.se
# 
#  This file should be in ${CSS_DIR}/ 
#
cd \${HOME}

"${CSS_GENERIC_DIR}/ESS CS-Studio" "\$@"


EOF

    chmod a+x ${css_hack_shell}
    ${SUDO_CMD} mv ${css_hack_shell} ${CSS_DIR}/ ;
    ${SUDO_CMD} ln -sf "${CSS_DIR}/css" /usr/local/bin/css
    
    __end_func ${func_name};
}


function define_css_user_home(){

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};

    local index=0
    local list_size=0
    local selected_one=0
    local user_home_list=()
    local selected_home=""
    
    # If an user, who executes this script, is not root,
    # set ${HOME} as CSS_USER_HOME
    
    if [[ $EUID -ne 0 ]]; then
	CSS_USER_HOME=${HOME};
    else
	user_home_list+=("root");
	user_home_list+=($(ls /home | grep -v "lost+found"));

	for tag in "${user_home_list[@]}"
	do
	    printf "%2s: home user %34s\n" "$index" "$tag"
	    let "index = $index + 1"
	done

	# type [ENTER], 0 is selected as default.
	echo -n "Select root (0, enter) or one of user home, followed by [ENTER]: "
	read -e line
   
	selected_one=${line}

	let "list_size = ${#user_home_list[@]} - 1"
    
	if [[ "$selected_one" -gt "$list_size" ]]; then
	    printf "\n>>> Please select one number smaller than %s\n" "${list_size}"
	    exit 1;
	fi
	if [[ "$selected_one" -lt 0 ]]; then
	    printf "\n>>> Please select one number larger than 0\n" 
	    exit 1;
	fi

	selected_user="$(tr -d ' ' <<< ${user_home_list[line]})";

	CSS_USER=${selected_user};
	
	if [[ "$selected_one" -eq 0 ]]; then
	    CSS_USER_HOME=/${selected_user};
	else
	    CSS_USER_HOME=/home/${selected_user};
	fi
	
	printf "\n>>> Selected %34s --- \n" "${CSS_USER_HOME}"
    fi
    
    __end_func ${func_name};
}


function update_css_configuration() {

    local func_name=${FUNCNAME[*]}; __ini_func ${func_name};
    
    local css_home_conf_dir=${CSS_USER_HOME}/configuration/;
    local css_main_conf_dir=${CSS_DIR}/configuration;
    local css_diirt_dir_at_home="${css_home_conf_dir}/diirt";
    local css_diirt_dir_at_main="${css_main_conf_dir}/diirt";

    local css_plugin_ini="plugin_customization.ini"
    
    if [[ -d ${css_diirt_dir_at_home} ]]; then
    	mv  ${css_diirt_dir_at_home}  ${css_diirt_dir_at_home}-OLD-${SC_LOGDATE}
	
    fi
    
    mkdir -p ${css_diirt_dir_at_home};
    
    pushd ${css_diirt_dir_at_home};
    /bin/cp -R ${css_diirt_dir_at_main}/* ${css_diirt_dir_at_home};
    popd;

    echo ${css_main_conf_dir}/${css_plugin_ini}
    ${SUDO_CMD} sed -i "s|org.csstudio.diirt.util.core.preferences/diirt.home=platform:/config/diirt|org.csstudio.diirt.util.core.preferences/diirt.home=${css_diirt_dir_at_home}|g" "${css_main_conf_dir}/${css_plugin_ini}"

    chown -R ${CSS_USER}.${CSS_USER} ${css_home_conf_dir}
    
    __end_func ${func_name};
}



declare -gr CSS_TOP="/opt";
declare -gr CSS_VERSION="4.5.1.0";
#declare -gr CSS_VERSION="4.5.0.2";
declare -gr CSS_GENERIC_NAME="cs-studio";
declare -gr CSS_GENERIC_DIR=${CSS_TOP}/${CSS_GENERIC_NAME};
#declare -gr CSS_DIR=${CSS_GENERIC_DIR}-${CSS_VERSION}
declare -gr CSS_DIR=${CSS_GENERIC_DIR}
declare -gr CSS_TYPE="production"
declare -gr CSS_DEPLOY_DIR=${CSS_DIR}_${SC_LOGDATE}

declare -g  CSS_USER=""
declare -g  CSS_USER_HOME=""
declare -gr SUDO_CMD="sudo";


wget_command="wget -c"
tar_command="tar xzf"


download_css

define_css_user_home

update_css_configuration
