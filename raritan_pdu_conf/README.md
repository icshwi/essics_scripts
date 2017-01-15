


http://ram.raritanassets.com/PDU_USB_Flash_Setup_and_Config.pdf


## USB Flash Drive

The USB should be connected to the **USB-A** slot on Raritan PDU

### fwupdate.cfg
the first file that the power strip references. It MUST be named fwupdate.cfg (the rest of the names below are 
suggestions per the example syntax). This tells the power strip what to do.

### config.txt 
 list of COMMON settings to place on every power strip.

### devicelist.csv 
 comma separated list of all power strips, by serial number, indicating the UNIQUE settings to pl
ace on each power strip.

### log.txt 
-  file where the power strip will indicate errors (if they occur).


```
$ touch fwupdate.cfg config.txt devicelist.csv log.txt README.md
$ tree -L 1 -A 
.
├── [jhlee     554]  config.txt
├── [jhlee     228]  devicelist.csv
├── [jhlee     101]  fwupdate.cfg
├── [jhlee       0]  log.txt
└── [jhlee     141]  README.md
```


## Reference
* http://ram.raritanassets.com/PDU_USB_Flash_Setup_and_Config.pdf
* http://www.raritan.com/blog/detail/how-to-rapidly-configure-intelligent-rack-pdus
