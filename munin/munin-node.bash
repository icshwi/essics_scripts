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
#   date    : Friday, September  8 16:34:34 CEST 2017
#   version : 0.0.4


declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"

: ${HOSTNAME?"Please Define hostname first"}

set -a
. ${SC_TOP}/munin-env.conf
set +a


${SUDO_CMD} -v

${SUDO_CMD} yum -y install epel-release
${SUDO_CMD} yum -y install munin-node munin-java-plugins munin-ruby-plugins munin-async munin-cgi munin-common munin-netip-plugins ethtool  cpan perl-libxml-perl
${SUDO_CMD} yum -y install git tree emacs screen telnet ipmitool
${SUDO_CMD} yum -y groupinstall "Development tools"

export PERL_MM_USE_DEFAULT=1 && sudo -E perl -MCPAN -e 'install "Module::Build"; install "Net::Server"; install "Net::Server::Fork"; install "Time::HiRes"; install "Net::SNMP"; install "CGI::Fast"; install "Digest::MD5"; install "File::Copy::Recursive"; install "Getopt::Long"; install "HTML::Template"; install "IO::Socket::INET6"; install "Params::Validate"; install "Storable"; install "Text::Balanced"; install "Net::CIDR";'




## in case we are using the firewalld. 
# /usr/lib/firewalld/services/munin-node.xml
# add the munin-node in the firewalled service

${SUDO_CMD} firewall-cmd --zone=public --add-service=munin-node --permanent
${SUDO_CMD} firewall-cmd --reload


# ESS DM Ansible mess iptable up, so one should enable the telnet connection from Munin-master (Server)
# to 4949 port 

${SUDO_CMD} iptables -I INPUT -p tcp -s ${MUNIN_MASTER_IP}/32 --dport ${MUNIN_NODE_PORT} -j ACCEPT



${SUDO_CMD} systemctl enable munin-node
${SUDO_CMD} munin-node-configure --shell --families=contrib,auto | ${SUDO_CMD} sh -x
${SUDO_CMD} systemctl start munin-node

pushd ${SC_TOP}

mkdir -p tmp
cat > ./tmp/${MUNIN_NODE_M4} <<EOF
include(\`${MUNIN_NODE_CONF_M4}')
MUNIN_NODE(\`${HOSTNAME}', \`${MUNIN_MASTER_IP}', \`${MUNIN_NODE_PORT}')
EOF


m4 ./tmp/${MUNIN_NODE_M4}  > ./tmp/munin-node.conf

${SUDO_CMD} install -m 644 ./tmp/munin-node.conf ${MUNIN_HOME}

popd


${SUDO_CMD} systemctl restart munin-node

