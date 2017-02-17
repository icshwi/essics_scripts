[iocuser@localhost ~]$ mkdir ics_gitsrc
[iocuser@localhost ~]$ cd ics_gitsrc/
[iocuser@localhost ics_gitsrc]$  curl -L https://git.io/vMyeU -o css_setup.bash
[iocuser@localhost ics_gitsrc]$ bash css_setup.bash 
[iocuser@localhost ics_gitsrc]$ git clone https://github.com/jeonghanlee/pciids
[iocuser@localhost ics_gitsrc]$ cd pciids/
[iocuser@localhost pciids]$ bash replace-pciids.bash 
centos was determined.
[sudo] password for iocuser: 


[iocuser@localhost ics_gitsrc]$ cd essics_scripts/
[iocuser@localhost essics_scripts]$ bash systemInfo.bash 

System Information generated at 2017Feb17-1643-18CET

Kernel     Version : 3.10.0-229.7.2.el7.x86_64
CentOS     Version : 7.1.1503
JAVA       Version : 1.8.0_40
CS Studio  Version : 4.4.1.3
EPICS Bases Path   : /opt/epics/bases
EPICS Modules path : /opt/epics/modules
EPICS Host Arch    : centos7-x86_64
EPICS BASE         : /opt/epics/bases/base-3.15.4
EPICS_ENV_PATH     : /opt/epics/modules/environment/1.8.2/3.15.4/bin/centos7-x86_64

OS Release Information 
PRETTY_NAME    = CentOS Linux 7 (Core)
NAME           = CentOS Linux
VERSION_ID     = 7
VERSION        = 7 (Core)
ID             = centos
HOME_URL       = https://www.centos.org/
SUPPORT_URL    = 
BUG_REPORT_URL = https://bugs.centos.org/
[iocuser@localhost essics_scripts]$ 

[iocuser@localhost ics_gitsrc]$ git clone https://github.com/icshwi/icsem_scripts
[iocuser@localhost ics_gitsrc]$ cd icsem_scripts/

[iocuser@localhost icsem_scripts]$ bash mrf_setup.bash show
[iocuser@localhost icsem_scripts]$ bash mrf_setup.bash src
[iocuser@localhost icsem_scripts]$ bash mrf_epicsEnvSet.bash


