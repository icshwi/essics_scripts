## Quick and Dirty way to compile the MRF and TOSCA kernel modules


In Host, first run the following commands (it doesn't matter to compile or not)

```
./kmodManager mrf
./kmodManager tsc
```

Then, copy the entire essics_scripts into the rootfs 


```
rm -rf /export/nfsroot/ifc1410-ess/home/root/ics_gitsrc/essics_scripts
scp -r essics_scripts /export/nfsroot/ifc1410-ess/home/root/ics_gitsrc/

```

Login the ifc1410

* in case, the first login into...

```
$ cd /usr/src/kernel
$ make ifc1410_defconfig modules_prepare
```
* next anytime

```
$ cd /home/root/essics_scripts/ioxos_kmod
$ ./kmodManager mrf_ifc1410
$ ./kmodManager tsc_ifc1410

```

## ntp is needed!!

```
make[2]: warning:  Clock skew detected.  Your build may be incomplete.


ntpdate 10.0.7.53 
16 Mar 00:42:24 ntpdate[3255]: adjust time server 10.0.7.53 offset 0.318090 sec
```


