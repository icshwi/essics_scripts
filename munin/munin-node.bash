#!/bin/bash
#
#  Copyright (c) 2017 - Present  Jeong Han Lee
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
#   date    : Tuesday, October 24 13:30:40 CEST 2017
#   version : 0.0.6


declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"

: ${HOSTNAME?"Please Define hostname first"}

set -a
. ${SC_TOP}/munin-env.conf
set +a


function pushd { builtin pushd "$@" > /dev/null; }
function popd  { builtin popd  "$@" > /dev/null; }



function yes_or_no_to_go {

    printf "\n";
    printf  ">>>> $1\n";
    read -p ">>>> Do you want to continue (y/n)? " answer
    case ${answer:0:1} in
	y|Y )
	    printf ">>>> munin-node will be be installed ...... ";
	    ;;
	* )
            printf "Stop here.\n";
	    exit;
    ;;
    esac

}



function find_dist {

    local dist_id dist_cn dist_rs PRETTY_NAME
    
    if [[ -f /usr/bin/lsb_release ]] ; then
     	dist_id=$(lsb_release -is)
     	dist_cn=$(lsb_release -cs)
     	dist_rs=$(lsb_release -rs)
     	echo $dist_id ${dist_cn} ${dist_rs}
    else
     	eval $(cat /etc/os-release | grep -E "^(PRETTY_NAME)=")
	echo ${PRETTY_NAME}
    fi

 
}



function install_perl_pkgs {
    export PERL_MM_USE_DEFAULT=1 && sudo -E perl -MCPAN -e 'install "Module::Build"; install "Net::Server"; install "Net::Server::Fork"; install "Time::HiRes"; install "Net::SNMP"; install "CGI::Fast"; install "Digest::MD5"; install "File::Copy::Recursive"; install "Getopt::Long"; install "HTML::Template"; install "IO::Socket::INET6"; install "Params::Validate"; install "Storable"; install "Text::Balanced"; install "Net::CIDR";'
}



function setup_for_centos {

    ${SUDO_CMD} -v

    ${SUDO_CMD} yum -y install epel-release
    ${SUDO_CMD} yum -y install munin-node munin-java-plugins munin-ruby-plugins munin-async munin-cgi munin-common munin-netip-plugins ethtool  cpan perl-libxml-perl 
    ${SUDO_CMD} yum -y install git tree emacs screen telnet ipmitool
    ${SUDO_CMD} yum -y groupinstall "Development tools"


    install_perl_pkgs 
    
    ## in case we are using the firewalld. 
    # /usr/lib/firewalld/services/munin-node.xml
    # add the munin-node in the firewalled service
    
    ${SUDO_CMD} firewall-cmd --zone=public --add-service=munin-node --permanent
    ${SUDO_CMD} firewall-cmd --reload
    
    
    # ESS DM Ansible mess iptable up, so one should enable the telnet connection from Munin-master (Server)
    # to 4949 port
    # In the case, no service is installed (no DM)
    ${SUDO_CMD} yum -y install iptables-service 
    ${SUDO_CMD} systemctl enable iptables
    
    # In the case, iptables service is not running. If the service is running, nothing happens
    
    ${SUDO_CMD} systemctl start iptables
    
    # Add the rule for munin 
    ${SUDO_CMD} iptables -I INPUT -p tcp -s ${MUNIN_MASTER_IP}/32 --dport ${MUNIN_NODE_PORT} -j ACCEPT
    
    # Save the rule in /etc/sysconfig/iptable (with iptable-service)
    ${SUOD_CMD} iptables-save > /etc/sysconfig/iptable
    
    # Restart the service in order to load the saved configuraton
    ${SUDO_CMD} systemctl start iptables

    ${SUDO_CMD} systemctl enable munin-node
    ${SUDO_CMD} munin-node-configure --shell --families=contrib,auto | ${SUDO_CMD} sh -x

    ${SUDO_CMD} systemctl restart httpd
    ${SUDO_CMD} systemctl start munin-node
    
}


function munin-node-setup {

    local munin_node_conf_m4_file=$1
    pushd ${SC_TOP}
    
    mkdir -p tmp
    cat > ./tmp/${MUNIN_NODE_M4} <<EOF
include(\`${munin_node_conf_m4_file}')
MUNIN_NODE(\`${HOSTNAME}', \`${MUNIN_MASTER_IP}', \`${MUNIN_NODE_PORT}')
EOF
    

    m4 ./tmp/${MUNIN_NODE_M4}  > ./tmp/munin-node.conf
    
    ${SUDO_CMD} install -m 644 ./tmp/munin-node.conf ${MUNIN_HOME}
    
    popd
    
    
  
 #   ${SUDO_CMD} systemctl restart apache2
    # CentOS7.4 has httpd service
 #   ${SUDO_CMD} systemctl restart httpd
    ${SUDO_CMD} systemctl restart munin-node
    
}



function setup_for_debian {


    printf "\n";
    ${SUDO_CMD} -v

    ${SUDO_CMD} aptitude install -y munin-node  apache2 libcgi-fast-perl libapache2-mod-fcgid

    ${SUDO_CMD} a2enmod fcgid
    install_perl_pkgs 
        ## in case we are using the firewalld. 
    # /usr/lib/firewalld/services/munin-node.xml
    # add the munin-node in the firewalled service
    
    ${SUDO_CMD} firewall-cmd --zone=public --add-service=munin-node --permanent
    ${SUDO_CMD} firewall-cmd --reload
    
    ${SUDO_CMD} systemctl enable munin-node
    ${SUDO_CMD} munin-node-configure --shell --families=contrib,auto | ${SUDO_CMD} sh -x
    ${SUDO_CMD} systemctl start munin-node

 
    
}





dist=$(find_dist)

case "$dist" in
    *Debian*)
	
	yes_or_no_to_go "Debian is detected as $dist"
	setup_for_debian
	munin-node-setup "${DEBIAN_MUNIN_NODE_CONF_M4}"
	${SUDO_CMD} systemctl restart apache2
	;;
    *CentOS*)
	yes_or_no_to_go "CentOS is detected as $dist";
	setup_for_centos
	munin-node-setup "${CENTOS_MUNIN_NODE_CONF_M4}"
	${SUDO_CMD} systemctl restart httpd
	;;
    *)
	printf "\n";
	printf "Doesn't support the detected $dist\n";
	printf "Please contact jeonghan.lee@gmail.com\n";
	printf "\n";
	;;
esac

exit 0;


