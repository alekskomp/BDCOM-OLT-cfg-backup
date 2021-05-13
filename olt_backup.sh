#!/usr/bin/env bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Inventory file. Example: ./olt_backup.sh /opt/backup/olt_inventory.txt
Inventory=$1

# TFTP server parameters
TftpIP="192.168.20.20"
# TFTP path in OLT "copy" command. e.g.: "copy flash:startup-config tftp://${TftpRemotePath}startup-config 192.168.20.20"
TftpRemotePath="cfg/OLT/$(date +%Y-%m-%d)/"
# Local TFTP directory on the server:
TftpLocalPath="/srv/tftp/"

# OLT access parameters
OLTLogin="login"
OLTPassword="password"

# OLT directory parameters
OLTLogDir="/var/log/olt_backup_logs/"
OLTBackupDir="/srv/tftp/cfg/OLT/"

# Number of parallel telnet connection
NumProcs="5"

# Check $1 parameter
if [[ -z "$1" ]]; then
	exit
fi

# Create log directory:
if [[ ! -e "${OLTLogDir}" ]]; then
	mkdir -p "${OLTLogDir}"
fi

# Create directory for OLT backups
if [[ ! -e "${TftpLocalPath}""${TftpRemotePath}" ]]; then
	mkdir "${TftpLocalPath}""${TftpRemotePath}"
	chown -R tftp:tftp "${TftpLocalPath}"
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
		echo "copy flash:startup-config tftp://${TftpRemotePath}startup-config_${OLTName} ${TftpIP}"
		sleep 2
		echo "copy flash:ifindex-config tftp://${TftpRemotePath}ifindex-config_${OLTName} ${TftpIP}"
		sleep 2
		echo "copy flash:vos.conf tftp://${TftpRemotePath}vos.conf_${OLTName} ${TftpIP}"
		sleep 2
		echo "copy flash:config.db tftp://${TftpRemotePath}config.db_${OLTName} ${TftpIP}"
		sleep 10
		echo "quit"
		sleep 1
		echo "quit"
	) | telnet ${OLTIPAddr} | tee ${OLTLogDir}$(date +%Y-%m-%d)_${OLTName}_${OLTIPAddr}.log &&
	cd ${TftpLocalPath}${TftpRemotePath}
	if [[ -f vos.conf_${OLTName} ]]; then
		tar --force-local -czf ${OLTName}_${OLTIPAddr}.tar.gz startup-config_${OLTName} ifindex-config_${OLTName} config.db_${OLTName} vos.conf_${OLTName} &&
		rm -f startup-config_${OLTName} ifindex-config_${OLTName} config.db_${OLTName} vos.conf_${OLTName}
	else
		tar --force-local -czf ${OLTName}_${OLTIPAddr}.tar.gz startup-config_${OLTName} ifindex-config_${OLTName} config.db_${OLTName} &&
		rm -f startup-config_${OLTName} ifindex-config_${OLTName} config.db_${OLTName}
	fi
}

# Main loop
for ((i = 0; i < NumProcs; i++)); do
	(
		while read -r OLTName OLTIPAddr OLTModel; do
			PingResult=$(ping -c 3 -W 1 -A ${OLTIPAddr} | grep transmitted | awk '{ print $6 }')
			if [[ ${PingResult} != "100%" ]]; then
				bdcom_olt
			fi
		done < <(awk -v NumProcs=${NumProcs} -v i="$i" \
			'NR % NumProcs == i { print }' < ${Inventory})
	) &
done
wait

# Delete old logs
find ${OLTLogDir} -type f -name '*' -mtime +14 -exec rm -rf {} \;

# Delete old backups
find ${OLTBackupDir} -type d -name '*' -mtime +120 -exec rm -rf {} \;