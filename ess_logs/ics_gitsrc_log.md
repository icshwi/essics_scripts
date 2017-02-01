## Make the ICS git source dir
```
[iocuser@localhost ~]$ mkdir ics_gitsrc
[iocuser@localhost ~]$ cd ics_gitsrc/
```
## Install CSS
```
[iocuser@localhost ics_gitsrc]$  curl -L https://git.io/vMyeU -o css_setup.bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100  7588  100  7588    0     0   6935      0  0:00:01  0:00:01 --:--:--  6935

[iocuser@localhost ics_gitsrc]$ bash css_setup.bash 

>>>> You are entering in  : download_css
--2017-02-01 16:19:28--  https://artifactory01.esss.lu.se/artifactory/CS-Studio/production/4.4.1.3/cs-studio-ess-4.4.1.3-linux.gtk.x86_64.tar.gz
Resolving artifactory01.esss.lu.se (artifactory01.esss.lu.se)... 194.47.240.107
Connecting to artifactory01.esss.lu.se (artifactory01.esss.lu.se)|194.47.240.107|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 193221086 (184M) [application/x-gzip]
Saving to: ‘cs-studio-ess-4.4.1.3-linux.gtk.x86_64.tar.gz’

100%[==============================================================================>] 193,221,086 48.2MB/s   in 3.9s   

2017-02-01 16:19:32 (47.1 MB/s) - ‘cs-studio-ess-4.4.1.3-linux.gtk.x86_64.tar.gz’ saved [193221086/193221086]

[sudo] password for iocuser: 

<<<< You are leaving from : download_css

>>>> You are entering in  : define_css_user_home

<<<< You are leaving from : define_css_user_home

>>>> You are entering in  : update_css_configuration
/opt/cs-studio-4.4.1.3/configuration/plugin_customization.ini

<<<< You are leaving from : update_css_configuration
```



## PCI.IDS

* Cloning the sort of ESS customized PCI.IDS db

```
[iocuser@localhost ics_gitsrc]$ git clone https://github.com/jeonghanlee/pciids
Cloning into 'pciids'...
remote: Counting objects: 386, done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 386 (delta 2), reused 0 (delta 0), pack-reused 380
Receiving objects: 100% (386/386), 1.23 MiB | 999.00 KiB/s, done.
Resolving deltas: 100% (133/133), done.
```



* Check the pci.ids file

```
[iocuser@localhost pciids]$ ls -ltar  /usr/share/hwdata/pci.ids 
-rw-r--r--. 1 root root 954291 May 12  2015 /usr/share/hwdata/pci.ids


[iocuser@localhost pciids]$ head -n 5 /usr/share/hwdata/pci.ids 
#
#	List of PCI ID's
#
#	Version: 2015.01.28
#	Date:    2015-01-28 03:15:02
```

* Replace it

```
[iocuser@localhost pciids]$ bash replace-pciids.bash 
centos was determined.
[sudo] password for iocuser: 

[iocuser@localhost pciids]$ ls -ltar  /usr/share/hwdata/pci.ids 
-rw-r--r--. 1 root root 1059815 Feb  1 15:29 /usr/share/hwdata/pci.ids
[iocuser@localhost pciids]$ head -n 5 /usr/share/hwdata/pci.ids 
#
#	List of PCI ID's
#
#	Version: 2017.01.28
#	Date:    2017-01-28 03:15:02
```


* Check MRF products by the ventor's id (1a3e)
```
[iocuser@localhost pciids]$ lspci -nmmn | grep -E "\<(1a3e)"
07:00.0 "Signal processing controller [1180]" "Xilinx Corporation [10ee]" "XILINX PCI DEVICE [7011]" "Micro-Research Finland Oy [1a3e]" "MTCA Event Receiver 300 [132c]"

* Check Struck products by the ventor's id (1796)

[iocuser@localhost pciids]$ lspci -nmmn | grep -E "\<(1796)"
05:00.0 "Unassigned class [ff00]" "Research Centre Juelich [1796]" "SIS8300-L(2) [MicroTCA.4 digitizer] [0019]" "Research Centre Juelich [1796]" "SIS8300-L(2) [MicroTCA.4 digitizer] [0019]"
```



## Setup MRF environment

* Cloning ...
```
[iocuser@localhost ics_gitsrc]$ git clone https://github.com/jeonghanlee/icsem_scripts
Cloning into 'icsem_scripts'...
remote: Counting objects: 231, done.
remote: Compressing objects: 100% (5/5), done.
remote: Total 231 (delta 1), reused 0 (delta 0), pack-reused 226
Receiving objects: 100% (231/231), 124.38 KiB | 0 bytes/s, done.
Resolving deltas: 100% (110/110), done.
```

* Check the following info

```
[iocuser@localhost ics_gitsrc]$ cd icsem_scripts/
[iocuser@localhost icsem_scripts]$ bash mrf_setup.bash 

usage: mrf_setup.bash <arg>

          <arg> : info

          show  : show the found mrf boards information 

          pac   : mrf package from ESS (do not use now) 
                  We are working on this.... 

          src   : compile kernel module from git repository 
                  https://bitbucket.org/europeanspallationsource/m-epics-mrfioc2
                  tag name : ess-2-7

          rule : put only the mrf kernel and udev rules 

[iocuser@localhost icsem_scripts]$ bash mrf_setup.bash show

We've found the MRF boards as follows:
--------------------------------------
07:00.0 "Signal processing controller [1180]" "Xilinx Corporation [10ee]" "XILINX PCI DEVICE [7011]" "Micro-Research Finland Oy [1a3e]" "MTCA Event Receiver 300 [132c]"

```

ICS uses the following mrfioc2 source :
```
- https://bitbucket.org/europeanspallationsource/m-epics-mrfioc2
- ess-2-7
```
in order to deploy any MRF products except the VME-EVG-230 and VME-EVR-230 now (2017.02.01). 
So, if one sees the different source, please let Han and Javier know immedidately. 


* Setup the MRF kernel module and its environment 
```
[iocuser@localhost icsem_scripts]$ bash mrf_setup.bash src
[sudo] password for iocuser: 

>>>> You are entering in  : git_compile_mrf

>>>> You are entering in  : git_clone
No git source repository in the expected location /home/iocuser/ics_gitsrc/icsem_scripts/m-epics-mrfioc2
Cloning into '/home/iocuser/ics_gitsrc/icsem_scripts/m-epics-mrfioc2'...
remote: Counting objects: 460, done.
remote: Compressing objects: 100% (364/364), done.
remote: Total 460 (delta 156), reused 246 (delta 84)
Receiving objects: 100% (460/460), 1.76 MiB | 1.09 MiB/s, done.
Resolving deltas: 100% (156/156), done.

<<<< You are leaving from : git_clone
~/ics_gitsrc/icsem_scripts/m-epics-mrfioc2/mrmShared/linux ~/ics_gitsrc/icsem_scripts
make -C /lib/modules/3.10.0-229.7.2.el7.x86_64/build M=/home/iocuser/ics_gitsrc/icsem_scripts/m-epics-mrfioc2/mrmShared/linux modules
make[1]: Entering directory `/usr/src/kernels/3.10.0-229.7.2.el7.x86_64'
  CC [M]  /home/iocuser/ics_gitsrc/icsem_scripts/m-epics-mrfioc2/mrmShared/linux/uio_mrf.o
  CC [M]  /home/iocuser/ics_gitsrc/icsem_scripts/m-epics-mrfioc2/mrmShared/linux/jtag_mrf.o
  LD [M]  /home/iocuser/ics_gitsrc/icsem_scripts/m-epics-mrfioc2/mrmShared/linux/mrf.o
  Building modules, stage 2.
  MODPOST 1 modules
  CC      /home/iocuser/ics_gitsrc/icsem_scripts/m-epics-mrfioc2/mrmShared/linux/mrf.mod.o
  LD [M]  /home/iocuser/ics_gitsrc/icsem_scripts/m-epics-mrfioc2/mrmShared/linux/mrf.ko
make[1]: Leaving directory `/usr/src/kernels/3.10.0-229.7.2.el7.x86_64'
make -C /lib/modules/3.10.0-229.7.2.el7.x86_64/build M=/home/iocuser/ics_gitsrc/icsem_scripts/m-epics-mrfioc2/mrmShared/linux modules_install
make[1]: Entering directory `/usr/src/kernels/3.10.0-229.7.2.el7.x86_64'
  INSTALL /home/iocuser/ics_gitsrc/icsem_scripts/m-epics-mrfioc2/mrmShared/linux/mrf.ko
Can't read private key
  DEPMOD  3.10.0-229.7.2.el7.x86_64
make[1]: Leaving directory `/usr/src/kernels/3.10.0-229.7.2.el7.x86_64'
make -C /lib/modules/3.10.0-229.7.2.el7.x86_64/build M=/home/iocuser/ics_gitsrc/icsem_scripts/m-epics-mrfioc2/mrmShared/linux clean
make[1]: Entering directory `/usr/src/kernels/3.10.0-229.7.2.el7.x86_64'
  CLEAN   /home/iocuser/ics_gitsrc/icsem_scripts/m-epics-mrfioc2/mrmShared/linux/.tmp_versions
  CLEAN   /home/iocuser/ics_gitsrc/icsem_scripts/m-epics-mrfioc2/mrmShared/linux/Module.symvers
make[1]: Leaving directory `/usr/src/kernels/3.10.0-229.7.2.el7.x86_64'
~/ics_gitsrc/icsem_scripts

<<<< You are leaving from : git_compile_mrf

>>>> You are entering in  : modprobe_mrf

<<<< You are leaving from : modprobe_mrf

>>>> You are entering in  : put_mrf_rule
Put the rule : mrf in /etc/modules-load.d/mrf.conf to load the mrf module at boot time.
mrf
<<<< You are leaving from : put_mrf_rule

>>>> You are entering in  : put_udev_rule
Put the rule : SUBSYSTEM=="uio", ATTR{name}=="mrf-pci", MODE="0666" in /etc/udev/rules.d/mrf.rules to be accessible via an user.
SUBSYSTEM=="uio", ATTR{name}=="mrf-pci", MODE="0666"
<<<< You are leaving from : put_udev_rule
 0: SCRPIT      : /home/iocuser/ics_gitsrc/icsem_scripts/mrf_setup.bash
 1: SCRIPT NAME : mrf_setup.bash
 2: SCRIPT TOP  : /home/iocuser/ics_gitsrc/icsem_scripts
 3: LOGDATE     : 2017Feb01-1602-28CET
 4: filename:       /lib/modules/3.10.0-229.7.2.el7.x86_64/extra/mrf.ko
author:         Michael Davidsaver <mdavidsaver@bnl.gov>
version:        1
license:        GPL v2
rhelversion:    7.1
srcversion:     9E849DD3775C8555B8B88BF
depends:        parport,uio
vermagic:       3.10.0-229.7.2.el7.x86_64 SMP mod_unload modversions 
parm:           cable:Name of JTAG parallel port cable to emulate (charp)
parm:           interfaceversion:User space interface version (int)
 5: mrf                    17592  0 
uio                    19259  1 mrf
parport                42348  1 mrf
```

```
[iocuser@localhost icsem_scripts]$ lsmod |grep mrf
mrf                    17592  0 
uio                    19259  1 mrf
parport                42348  1 mrf


[iocuser@localhost icsem_scripts]$ modinfo mrf
filename:       /lib/modules/3.10.0-229.7.2.el7.x86_64/extra/mrf.ko
author:         Michael Davidsaver <mdavidsaver@bnl.gov>
version:        1
license:        GPL v2
rhelversion:    7.1
srcversion:     9E849DD3775C8555B8B88BF
depends:        parport,uio
vermagic:       3.10.0-229.7.2.el7.x86_64 SMP mod_unload modversions 
parm:           cable:Name of JTAG parallel port cable to emulate (charp)
parm:           interfaceversion:User space interface version (int)
```



* Reboot

```
[iocuser@localhost ics_gitsrc]$ modinfo mrf
filename:       /lib/modules/3.10.0-229.7.2.el7.x86_64/extra/mrf.ko
author:         Michael Davidsaver <mdavidsaver@bnl.gov>
version:        1
license:        GPL v2
rhelversion:    7.1
srcversion:     9E849DD3775C8555B8B88BF
depends:        parport,uio
vermagic:       3.10.0-229.7.2.el7.x86_64 SMP mod_unload modversions 
parm:           cable:Name of JTAG parallel port cable to emulate (charp)
parm:           interfaceversion:User space interface version (int)

[iocuser@localhost ics_gitsrc]$ lsmod |grep mrf
mrf                    17592  0 
uio                    19259  1 mrf
parport                42348  1 mrf
```

* One more thing....
One can get the full information of any mrf products are installed in a system via the following command without looking at outputs of each lspci command. The script returns the EPICS startup script format, so one can tweak it a bit, and copy and paste in their startup script quickly.




```
[iocuser@localhost icsem_scripts]$ bash mrf_epicsEnvSet.bash 


>>>>>>>>>>>>>>>>>>> snip snip >>>>>>>>>>>>>>>>>>>

# ESS EPICS Environment

#
# iocsh -3.14.12.5 "e3_startup_script".cmd
# require mrfioc2,edit_me

epicsEnvSet(       "SYS"     "edit_me")
epicsEnvSet(       "EVR"     "edit_me")
epicsEnvSet(   "EVR_BUS"        "0x07")
epicsEnvSet(   "EVR_DEV"        "0x00")
epicsEnvSet(  "EVR_FUNC"         "0x0")
epicsEnvSet("EVR_DOMAIN"      "0x0000")

mrmEvrSetupPCI($(EVR), $(EVR_DOMAIN), $(EVR_BUS), $(EVR_DEV), $(EVR_FUNC))

# dbLoadRecords example
# dbLoadRecords("edit_me", "DEVICE=$(EVR), SYS=$(SYS)")

<<<<<<<<<<<<<<<<<<< snip snip <<<<<<<<<<<<<<<<<<<
```

### Check the basic system information

* Cloning ....

```
[iocuser@localhost ics_gitsrc]$ git clone https://github.com/jeonghanlee/essics_scripts
Cloning into 'essics_scripts'...
remote: Counting objects: 107, done.
remote: Compressing objects: 100% (16/16), done.
remote: Total 107 (delta 3), reused 0 (delta 0), pack-reused 91
Receiving objects: 100% (107/107), 38.24 KiB | 0 bytes/s, done.
Resolving deltas: 100% (39/39), done.
```

* Run systemInfo

Note that the way to get cs-studio version should be re-implemented later. (Han)

```
[iocuser@localhost essics_scripts]$ bash systemInfo.bash 
cat: /opt/cs-studio/ess-version.txt: No such file or directory

System Information generated at 2017Feb01-1704-16CET

Kernel     Version : 3.10.0-229.7.2.el7.x86_64
CentOS     Version : 7.1.1503
JAVA       Version : 1.8.0_40
CS Studio  Version : 
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
```

* Check the repository files 
```
[iocuser@localhost essics_scripts]$ ls -ltar /etc/yum.repos.d/*
-rw-r--r--. 1 root root 1700 Jan 20 15:10 /etc/yum.repos.d/CentOS-Base.repo
-rw-r--r--. 1 root root  957 Jan 20 15:10 /etc/yum.repos.d/epel.repo
-rw-r--r--. 1 root root 1056 Jan 20 15:10 /etc/yum.repos.d/epel-testing.repo
-rw-r--r--. 1 root root 1012 Jan 20 15:10 /etc/yum.repos.d/CentOS-Vault-7.1.1503.repo
-rw-r--r--. 1 root root  194 Jan 20 15:10 /etc/yum.repos.d/devenv-extras.repo
-rw-r--r--. 1 root root  428 Jan 20 15:10 /etc/yum.repos.d/epel-19012016.repo
```

I (Han) still have no idea why DM has more than what it should have. For example, 
CentOS-Base.repo, epel.repo, and epel-testing.repo.....

