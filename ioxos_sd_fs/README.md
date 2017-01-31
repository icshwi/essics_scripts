# using systemd to load its kernel module and change itsIRQ thread priority:

ioxos_sd.boot puts the pevautostart.service in the following directory :
```
/lib/systemd/system/
```

But we have to run the following commands after the first boot on IOxSO, because I don't want to change anything on the existent rootfs

```
root@localhost:~# systemctl status pevautostart
● pevautostart.service - PEV Kernel module and its IRQ prio
   Loaded: loaded (/home/root/essics_scripts/initPev.sh; disabled)
   Active: inactive (dead)
   
root@localhost:~# systemctl status pevautostart
root@localhost:~# systemctl enable  pevautostart
root@localhost:~# reboot
```


After rebooting the IOxOS, one can check this status as well.



```
root@localhost:~# systemctl status pevautostart -l
● pevautostart.service - PEV Kernel module and its IRQ prio
   Loaded: loaded (/home/root/essics_scripts/initPev.sh; enabled)
   Active: inactive (dead) since Tue 2017-01-31 16:05:27 CET; 2min 12s ago
  Process: 2675 ExecStart=/home/root/essics_scripts/initPev.sh (code=exited, status=0/SUCCESS)
 Main PID: 2675 (code=exited, status=0/SUCCESS)

Jan 31 16:05:27 localhost initPev.sh[2675]: srcversion:     014F8ED2D11B725AE827460
Jan 31 16:05:27 localhost initPev.sh[2675]: depends:
Jan 31 16:05:27 localhost initPev.sh[2675]: vermagic:       3.14.39ltsi-rt37-yocto-preempt-rt SMP preempt mod_unload
Jan 31 16:05:27 localhost initPev.sh[2675]: Creating devices pev xmc1_ xmc2_ in /dev/
Jan 31 16:05:27 localhost initPev.sh[2675]: Creating pev xmc1_ xmc2_ devices...
Jan 31 16:05:27 localhost initPev.sh[2675]: Changing group and mode in  pev xmc1_ xmc2_ devices...
Jan 31 16:05:27 localhost initPev.sh[2675]: Check whether the kernel supports realtime features
Jan 31 16:05:27 localhost initPev.sh[2675]: This is the realtime patch system, and go further...
Jan 31 16:05:27 localhost initPev.sh[2675]: pev IRQ thread priority : Running:50  Max:98
Jan 31 16:05:27 localhost initPev.sh[2675]: Changing the pev IRQ thread priority from 50 to 98
```

