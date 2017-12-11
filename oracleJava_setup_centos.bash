#!/bin/bash
#
#  Copyright (c) 2017 - Present Jeong Han Lee
#  Copyright (c) 2017 - Present European Spallation Source ERIC

#  This shell script is free software: you can redistribute
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
# Date   : 
# version : 0.0.1


#declare -gr JDK_URL="http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.rpm"

declare -gr VER="152";

declare -gr JDK_VER="8u${VER}";

declare -gr JAVA_PATH="/usr/java/jdk1.8.0_${VER}"
declare -gr JDK_RPM="jdk-${JDK_VER}-linux-x64.rpm"
declare -gr ORACLE_KEY="090f390dda5b47b9b721c7dfaa008135";

declare -gr JDK_URL="http://download.oracle.com/otn-pub/java/jdk/${JDK_VER}-b01/${ORACLE_KEY}/${JDK_RPM}"

#wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" ${JDK_URL}


sudo yum localinstall ${JDK_RPM}


sudo alternatives --install /usr/bin/java   java    ${JAVA_PATH}/jre/bin/java 20000
# sudo alternatives --install /usr/bin/jar    jar     ${JAVA_PATH}/bin/jar 20000
sudo alternatives --install /usr/bin/javac  javac   ${JAVA_PATH}/bin/javac 20000
sudo alternatives --install /usr/bin/javaws javaws  ${JAVA_PATH}/jre/bin/javaws 20000




sudo alternatives --set     java    ${JAVA_PATH}/jre/bin/java
# sudo alternatives --set     jar     ${JAVA_PATH}/bin/jar
sudo alternatives --set     javac   ${JAVA_PATH}/bin/javac 
sudo alternatives --set     javaws  ${JAVA_PATH}/jre/bin/javaws


ls -lA /etc/alternatives/java*


java -version
