#!/usr/bin/sh

root=@FLASH_PATH@p
count=$(ls ${root}* | wc -l)
i=1
while [ $i -le $count ]
do
	devroot=${root}${i}
	for arg in $(blkid ${devroot}); do
		case "${arg}" in
			TYPE=*) eval ${arg};;
			PTTYPE=*) eval ${arg};;
		esac
	done

	dm_inc_name=introot${i}
	if [ -n "${TYPE}" ] && [ "${TYPE}" = "DM_integrity" ]; then
		integritysetup open ${devroot} --integrity sha256 --journal-integrity sha256 ${dm_inc_name}
		unset PTTYPE
		unset TYPE
		devroot=/dev/mapper/${dm_inc_name}
		for arg in $(blkid ${devroot}); do
			case "${arg}" in
				TYPE=*) eval ${arg};;
				PTTYPE=*) eval ${arg};;
			esac
		done
	fi
	dm_final_name=$(basename ${root})${i}
	if [ ! -n "${TYPE}" ] && [ ! -n "${PTTYPE}" ]; then
		if test -f ${CONFIG_MOUNTPATH}/secrets/tksecure_key.bb; then
			dmsetup create ${dm_final_name} --table "0 $(blockdev --getsz ${devroot}) crypt capi:tk(cbc(aes))-plain :64:logon:rootfs: 0 ${devroot} 0"
		else
			dmsetup create ${dm_final_name} --table "0 $(blockdev --getsz ${devroot}) crypt aes-xts-plain64 :64:encrypted:rootfs 0 ${devroot} 0"
		fi
	fi
	if [ -e /dev/mapper/${dm_inc_name} ] && [ ! -e /dev/mapper/${dm_final_name} ]; then
		dmsetup rename ${dm_inc_name} ${dm_final_name}
	fi
	let i=i+1
	unset TYPE
	unset PTTYPE
done
