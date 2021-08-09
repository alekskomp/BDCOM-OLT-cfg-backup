# BDCOM GEPON OLT configuration backup script

Script must run on tftp server.

It makes backups from multiple devices same time (tune "NumProcs" variable).

* Supported models:
```
P3310C
P3310D
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
ls -lh /srv/tftp/cfg/OLT/OLT_Pushkina_3/

-rw-r--r-- 1 root root 26K Jul 11 05:32 2021-07-11_OLT_Pushkina_3_192.168.10.10.tar.gz
-rw-r--r-- 1 root root 26K Jul 12 05:32 2021-07-12_OLT_Pushkina_3_192.168.10.10.tar.gz
-rw-r--r-- 1 root root 26K Jul 13 05:32 2021-07-13_OLT_Pushkina_3_192.168.10.10.tar.gz
-rw-r--r-- 1 root root 26K Jul 14 05:32 2021-07-14_OLT_Pushkina_3_192.168.10.10.tar.gz
-rw-r--r-- 1 root root 26K Jul 15 05:32 2021-07-15_OLT_Pushkina_3_192.168.10.10.tar.gz
```

Every archive contains:
```
config.db_OLT_Name
ifindex-config_OLT_Name
startup-config_OLT_Name
running-config_OLT_Name
```

* Cron job example:

```shell
/etc/cron.d/olt_backup 

0 5 * * * root /opt/backup/olt_backup.sh /opt/backup/olt_inventory.txt > /dev/null 2>&1
```
