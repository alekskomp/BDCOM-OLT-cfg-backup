#!/usr/bin/env bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Inventory file. Example: ./olt_backup.sh /opt/backup/bash/olt_inventory.txt
Inventory=$1

# TFTP IP
TftpIP="192.168.20.20"
# OLT access parameters
OLTLogin="login"
OLTPassword="password"
# Directory variables
TftpRemotePath="cfg/OLT/"
TftpLocalPath="/srv/tftp/"
OLTLogDir="/var/log/olt_backup_logs/"
OLTBackupDir="/srv/tftp/cfg/OLT/"
BackupDate="$(date +%Y-%m-%d)"
# Number of backups to keep
BackupCount="30"
# Number of parallel telnet connection
NumProcs="15"

# Check $1 parameter
if [[ -z $1 ]]; then
  exit
fi

# Create Backup directory:
if [[ ! -e ${OLTBackupDir} ]]; then
  mkdir -p ${OLTBackupDir}
  chown -R tftp:tftp ${TftpLocalPath}
fi

# Create log directory:
if [[ ! -e ${OLTLogDir} ]]; then
  mkdir -p ${OLTLogDir}
fi

# Template function for file transfer from OLT
bdcom_olt() {
  (
    sleep 2
    echo "${OLTLogin}"
    sleep 1
    echo "${OLTPassword}"
    sleep 1
    echo "enable"
    sleep 1
    echo "copy flash:startup-config tftp://${TftpRemotePath}${OLTName}/startup-config_${OLTName} ${TftpIP}"
    sleep 2
    echo "copy flash:ifindex-config tftp://${TftpRemotePath}${OLTName}/ifindex-config_${OLTName} ${TftpIP}"
    sleep 2
    echo "copy flash:vos.conf tftp://${TftpRemotePath}${OLTName}/vos.conf_${OLTName} ${TftpIP}"
    sleep 2
    echo "copy flash:config.db tftp://${TftpRemotePath}${OLTName}/config.db_${OLTName} ${TftpIP}"
    sleep 10
    echo "show running-config | redirect running-config"
    sleep 10
    echo "copy flash:running-config tftp://${TftpRemotePath}${OLTName}/running-config_${OLTName} ${TftpIP}"
    sleep 2
    echo "delete running-config"
    sleep 1
    echo "y"
    sleep 3
    echo "quit"
    sleep 1
    echo "quit"
  ) | telnet ${OLTIPAddr} | tee ${OLTLogDir}${OLTName}_${BackupDate}_${OLTIPAddr}.log
  cd ${OLTBackupDir}${OLTName}
  if [[ -f vos.conf_${OLTName} ]]; then
    tar --force-local -czf ${BackupDate}_${OLTName}_${OLTIPAddr}.tar.gz startup-config_${OLTName} ifindex-config_${OLTName} config.db_${OLTName} vos.conf_${OLTName} running-config_${OLTName} && \
    rm -f startup-config_${OLTName} ifindex-config_${OLTName} config.db_${OLTName} vos.conf_${OLTName} running-config_${OLTName}
  else
    tar --force-local -czf ${BackupDate}_${OLTName}_${OLTIPAddr}.tar.gz startup-config_${OLTName} ifindex-config_${OLTName} config.db_${OLTName} running-config_${OLTName} && \
    rm -f startup-config_${OLTName} ifindex-config_${OLTName} config.db_${OLTName} running-config_${OLTName}
    chown tftp:tftp ${OLTBackupDir}${OLTName}
  fi
}

# Main loop
for ((i = 0; i < NumProcs; i++)); do
  (
    while read -r OLTName OLTIPAddr OLTModel; do
      PingResult=$(ping -c 3 -W 1 -A ${OLTIPAddr} | grep transmitted | awk '{ print $6 }')
      if [[ ${PingResult} != "100%" ]]; then
        if [[ ! -e ${OLTBackupDir}${OLTName} ]]; then
          mkdir ${OLTBackupDir}${OLTName}
          chown tftp:tftp ${OLTBackupDir}${OLTName}
        fi
      bdcom_olt
      # Delete old backups
      find ${OLTBackupDir}${OLTName} -type f -printf '%T@\t%p\n' | sort | head -n -${BackupCount} | awk '{ print $2 }' | xargs -r rm
      fi
    done < <(awk -v NumProcs=${NumProcs} -v i="$i" 'NR % NumProcs == i { print }' < ${Inventory})
  ) &
done
wait

# Delete old logs
find ${OLTLogDir} -type f -name '*' -mtime +14 -exec rm -rf {} \;
