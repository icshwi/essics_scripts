#!/bin/bash
#
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
#   date    : 
#   version : 0.0.1


sudo yum -y install epel-release
sudo yum -y install munin-node munin-java-plugins munin-netip-plugins cpan
sudo yum -y install git tree emacs screen telnet 
sudo yum -y groupinstall "Development tools"


sudo perl -MCPAN -e 'install "Module::Build"; install "Net::Server"; install "Net::Server::Fork"; install "Time::HiRes"; install "Net::SNMP"; install "CGI::Fast"; install "Digest::MD5"; install "File::Copy::Recursive"; install "Getopt::Long"; install "HTML::Template"; install "IO::Socket::INET6"; install "Params::Validate"; install "Storable"; install "Text::Balanced";'


## Edit /etc/munin-node.conf 
## host_name icslab-ser01
## cidr_allow 10.0.0.0/16


# /usr/lib/firewalld/services/munin-node.xml


# add the munin-node in the firewalled service

sudo firewall-cmd --zone=public --add-service=munin-node --permanent
sudo firewall-cmd --reload

sudo systemctl enable munin-node
#sudo systemctl start munin-node
