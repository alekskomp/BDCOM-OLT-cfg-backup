# BDCOM GEPON OLT configuration backup script

Script must run on tftp server.

It makes backups from multiple devices same time (tune "NumProcs" variable).

* Supported models:
```
P3310C
P3608B
P3608-2TE
P3616-2TE
```

* Usage:
```
./olt_backup.sh olt_inventory.txt
```
Inventory file must be like this:

(name ip_address model)
```
OLT_Pushkina_3 192.168.10.10 P3310C
OLT_Lermontova_5 192.168.10.11 P3310C
OLT_Lenina_2 192.168.10.12 P3608B
OLT_Tolstogo_15 192.168.10.13 P3616-2TE
OLT_Gogolya_7 192.168.10.14 P3608B
```
You will get archives on your tftp server:
```
ls -lh /srv/tftp/cfg/OLT/2020-10-17/

-rw-r--r-- 1 root root  17K Nov 17 05:00 OLT_Pushkina_3_192.168.10.10.tar.gz
-rw-r--r-- 1 root root  13K Nov 17 05:00 OLT_Lermontova_5_192.168.10.11.tar.gz
-rw-r--r-- 1 root root  20K Nov 17 05:00 OLT_Lenina_2_192.168.10.12.tar.gz
-rw-r--r-- 1 root root  59K Nov 17 05:00 OLT_Tolstogo_15_192.168.10.13.tar.gz
-rw-r--r-- 1 root root  15K Nov 17 05:00 OLT_Gogolya_7_192.168.10.14.tar.gz
```

Every archive contains:
```
config.db_OLT_Name
ifindex-config_OLT_Name
startup-config_OLT_Name
```

* Cron job example:

```shell
/etc/cron.d/olt_backup 

0 5 * * * root /opt/backup/olt_backup.sh /opt/backup/olt_inventory.txt > /dev/null 2>&1
```