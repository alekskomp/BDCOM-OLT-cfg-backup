# BDCOM GEPON OLT configuration backup script

Script must be run on tftp server. In my case tftp runs on Debian.

It creates backups of several devices at the same time (tune `NumProcs` variable).

* Supported all BDCOM GEPON OLT models.

## Usage

```
./olt_backup.sh olt_inventory.txt
```

The inventory file should look like this:

(name ip_address model)
```
OLT_Pushkina_3 192.168.10.10 P3310C
OLT_Lermontova_5 192.168.10.11 P3310C
OLT_Lenina_2 192.168.10.12 P3608B
OLT_Tolstogo_15 192.168.10.13 P3616-2TE
OLT_Gogolya_7 192.168.10.14 P3608B
```
You will get the archives on your tftp server:
```
ls -lh /srv/tftp/OLT_backups/OLT_Pushkina_3/

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

/etc/cron.d/olt_backup
```shell
0 5 * * * root /opt/backup/olt_backup.sh /opt/backup/olt_inventory.txt > /dev/null 2>&1
```

Backup logs are stored in `/var/log/olt_backup_logs/` by default.
