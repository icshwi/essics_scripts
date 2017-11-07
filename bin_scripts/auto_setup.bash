#!/bin/bash

rm -rf {Music,Pictures,Public,Templates,Videos}

sudo yum remove -y firewalld

sudo yum install -y git

mkdir ics_gitsrc

cd ics_gitsrc/

git clone https://github.com/icshwi/essics_scripts
git clone https://github.com/icshwi/essdm_scripts
git clone https://github.com/jeonghanlee/pkg_automation

bash essics_scripts/iocuser_env/iocuser_env_setup.bash clean
bash essics_scripts/iocuser_env/iocuser_env_setup.bash install

# enable wget first in oracleJava_setup_centos.bash
#bash essics_scripts/oracleJava_setup_centos.bash 
#bash essdm_scripts/css_setup.bash 

bash pkg_automation/pkg_automation.bash
