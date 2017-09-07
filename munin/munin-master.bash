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
#
#   author  : Jeong Han Lee
#   email   : jeonghan.lee@gmail.com
#   date    : 
#   version : 0.0.1


sudo yum -y install httpd

sudo yum -y install munin munin-node munin-java-plugins munin-ruby-plugins munin-async munin-cgi munin-common munin-netip-plugins ethtool  cpan perl-libxml-perl


export PERL_MM_USE_DEFAULT=1 && sudo -E perl -MCPAN -e 'install "Module::Build"; install "Net::Server"; install "Net::Server::Fork"; install "Time::HiRes"; install "Net::SNMP"; install "CGI::Fast"; install "Digest::MD5"; install "File::Copy::Recursive"; install "Getopt::Long"; install "HTML::Template"; install "IO::Socket::INET6"; install "Params::Validate"; install "Storable"; install "Text::Balanced";'

