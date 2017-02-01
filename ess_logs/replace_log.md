### MRF Kernel module

```
[iocuser@localhost ics_gitsrc]$ lsmod |grep mrf
mrf                    17639  0 
uio                    19259  1 mrf
parport                42348  1 mrf
[iocuser@localhost ics_gitsrc]$ modinfo mrf
filename:       /lib/modules/3.10.0-229.7.2.el7.x86_64/extra/mrf.ko
author:         Michael Davidsaver <mdavidsaver@bnl.gov>
version:        1
license:        GPL v2
rhelversion:    7.1
srcversion:     5E0EB43A84EC6985FD73C4D
alias:          pci:v000010EEd00007011sv00001A3Esd0000132Cbc*sc*i*
alias:          pci:v00001204d0000EC30sv00001A3Esd0000172Cbc*sc*i*
alias:          pci:v000010B5d00009056sv00001A3Esd0000192Cbc*sc*i*
alias:          pci:v000010B5d00009030sv00001A3Esd000011E6bc*sc*i*
alias:          pci:v000010B5d00009030sv00001A3Esd000020E6bc*sc*i*
alias:          pci:v000010B5d00009030sv00001A3Esd000010E6bc*sc*i*
depends:        parport,uio
vermagic:       3.10.0-229.7.2.el7.x86_64 SMP mod_unload modversions 
parm:           cable:Name of JTAG parallel port cable to emulate (charp)
parm:           interfaceversion:User space interface version (int)

[iocuser@localhost ics_gitsrc]$ more /etc/udev/rules.d/88-mrf.rules 
KERNEL=="uio[0-9]*",  NAME="%k", MODE="0666"
[iocuser@localhost ics_gitsrc]$ 


```

* remove the mrf rules

```
[iocuser@localhost ics_gitsrc]$ sudo rm /etc/udev/rules.d/88-mrf.rules 
[sudo] password for iocuser: 
Sorry, try again.
[sudo] password for iocuser: 
[iocuser@localhost ics_gitsrc]$ more /etc/udev/rules.d/88-mrf.rules 
/etc/udev/rules.d/88-mrf.rules: No such file or directory

[iocuser@localhost ics_gitsrc]$ lsmod |grep mrf
mrf                    17639  0 
uio                    19259  1 mrf
parport                42348  1 mrf
[iocuser@localhost ics_gitsrc]$ sudo modprobe -r mrf
[iocuser@localhost ics_gitsrc]$ lsmod |grep mrf
[iocuser@localhost ics_gitsrc]$ 

[iocuser@localhost ics_gitsrc]$ sudo rm  /lib/modules/3.10.0-229.7.2.el7.x86_64/extra/mrf.ko

```

* Install MRF (in ics_gitsrc_log.md) 

We got the following infomation after rebooting the system.

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



## ESS CS-Studio


* Rename cs-studio to cs-studio-4.1.2

```
drwxr-xr-x.  2 root    root       6 Mar 26  2015 rh
drwxrwxrwx.  4 iocuser root      32 Oct  2  2015 epics
drwxrwxr-x.  6 root    root    4096 Jan 20 15:28 cs-studio_4.4.1.2_2017Jan20-1528-12CET
drwxr-xr-x.  6 root    root      88 Jan 23 15:38 .
dr-xr-xr-x. 17 root    root    4096 Jan 31 16:57 ..
drwxrwxr-x.  8 iocuser iocuser 4096 Feb  1 15:18 cs-studio

[root@localhost opt]# mv cs-studio cs-studio-4.1.2
```

* Remove the orphan css wrapper script from 4.4.1.2

```
[root@localhost opt]# rm  /usr/local/bin/css 
rm: remove symbolic link ‘/usr/local/bin/css’? y
```


* Setup CSS 4.4.1.3 (See ics_gitsrc_log.md)

```
drwxrwxrwx.  4 iocuser root      32 Oct  2  2015 epics
drwxrwxr-x.  6 root    root    4096 Jan 20 15:28 cs-studio_4.4.1.2_2017Jan20-1528-12CET
drwxrwxr-x.  8 iocuser iocuser 4096 Feb  1 15:18 cs-studio-4.1.2
dr-xr-xr-x. 17 root    root    4096 Feb  1 16:05 ..
lrwxrwxrwx.  1 root    root      43 Feb  1 16:19 cs-studio-4.4.1.3 -> /opt/cs-studio-4.4.1.3_2017Feb01-1619-28CET
drwxr-xr-x.  7 root    root    4096 Feb  1 16:19 .
drwxrwxr-x.  6 root    root    4096 Feb  1 16:19 cs-studio-4.4.1.3_2017Feb01-1619-28CET
```

* Make CSS 4.1.2 executable file name to match the file name of 4.4.1.3

``` 
[root@localhost opt]# cd cs-studio-4.1.2/
[root@localhost cs-studio-4.1.2]# ls -ltar
...........
-rwxr-xr-x.  1 iocuser iocuser 74675 Jun 25  2015 cs-studio
...........

[root@localhost cs-studio-4.1.2]# ln -s cs-studio "ESS CS-Studio"
[root@localhost cs-studio-4.1.2]# ls -ltar
...........
-rwxr-xr-x.  1 iocuser iocuser 74675 Jun 25  2015 cs-studio
lrwxrwxrwx.  1 root    root        9 Feb  1 16:21 ESS CS-Studio -> cs-studio
...........
```



