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
#   date    : 
#   version : 0.0.2


sudo yum -y install epel-release
sudo yum -y install munin-node munin-java-plugins munin-netip-plugins cpan
sudo yum -y install git tree emacs screen telnet 
sudo yum -y groupinstall "Development tools"

export PERL_MM_USE_DEFAULT=1 && sudo -E perl -MCPAN -e 'install "Module::Build"; install "Net::Server"; install "Net::Server::Fork"; install "Time::HiRes"; install "Net::SNMP"; install "CGI::Fast"; install "Digest::MD5"; install "File::Copy::Recursive"; install "Getopt::Long"; install "HTML::Template"; install "IO::Socket::INET6"; install "Params::Validate"; install "Storable"; install "Text::Balanced";'




## in case we are using the firewalld. 
# /usr/lib/firewalld/services/munin-node.xml
# add the munin-node in the firewalled service

sudo firewall-cmd --zone=public --add-service=munin-node --permanent
sudo firewall-cmd --reload


sudo systemctl enable munin-node
sudo munin-node-configure --shell
sudo systemctl start munin-node


# One must update the proper configuration in  /etc/munin/munin-node.conf 
# host_name icslab-ser01
# or one of the following
# cidr_allow 10.0.0.0/16        255.255.0.0
# cidr_allow 10.0.1.0/24        255.255.255.0
# The below option is highly recommended
# 
# cidr_allow 10.0.7.177/32      255.255.255.255
# 
# Restart munin-node after modification
# sudo  systemctl restart munin-node
