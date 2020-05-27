#!/bin/sh
#
#  secureboot-fileencrypt
#
#  Copyright (C) 2020 PHYTEC Messtechnik GmbH,
#  Author: Maik Otto <m.otto@phytec.de>
#
#  Released under the MIT license (see COPYING.MIT for the terms)
#

POWEROFF_TIME="10"

do_poweroff() {
    printf "\nThe system will poweroff in %s seconds" "${POWEROFF_TIME}"
    sleep "${POWEROFF_TIME}"
    sync && poweroff -f
    exit 0
}

do_login() {
    for arg in $(cat /proc/cmdline); do
        case "${arg}" in
            console=*) eval ${arg};;
        esac
    done
    ttydev="$(echo $console | cut -d',' -f1)"
    ttybaud="$(echo $console | cut -d',' -f2)"
    sync && /sbin/getty 115200 /dev/${ttydev}
    exit 0
}

checkresponse() {
    if [ $? -ne 0 ]; then
        [ ${#} -ge 1 ] && printf "\n[ERROR]: %s\n\n" "${2}"
        [ $1 -ne 0 ] &&  do_poweroff
        #go to login
        do_login
    fi
}

# Main
#------------------------------------------------------------------------------

mkdir -p /proc /sys /dev /mnt_secrets
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# Set kernel console loglevel
LOGLEVEL="$(sysctl -n kernel.printk)"
sysctl -q -w kernel.printk=4

for arg in $(cat /proc/cmdline); do
    case "${arg}" in
	rescue=1|root=*|rootfstype=*) eval ${arg};;
    esac
    if echo ${arg} | grep -q "ubi.mtd"; then
	ubimtd=$(echo ${arg##*ubi.mtd=})
    fi

done

# Translate "PARTUUID=..." to real device
root="$(findfs ${root})"

# go to login, when requested
[ -n "${rescue}" ] && do_login
# go to login, when ubifs
if [ "${rootfstype}" == "ubifs" ]; then
    printf "Please use FITImage without ramdisk for ubifs!\n"
    do_login
fi

mkdir -p /newroot
if echo "$root" | grep -q "mmc"; then
    #mmc or emmc => key example is in partition 3
    count=$(ls ${root%?}* | wc -l)
    i=1
    secret=""
    while [ $i -le $count ]
    do
        for arg in $(blkid ${root%?}${i}); do
            case "${arg}" in
                LABEL=*) eval ${arg};;
            esac
        done
        if echo "$LABEL" | grep -q "boot"; then
            secret=${root%?}${i}
            i=$count
        fi
        let i=i+1
    done
    [ ${#secret} -eq 0 ] && do_login
    mount ${secret} /mnt_secrets

    test -f /mnt_secrets/secrets/secure_key.blob
    checkresponse 0 "No secure_key.blob for Fileencryption in folder /mnt_secrets/secrets"
    keyctl add secure rootfs  "load `cat /mnt_secrets/secrets/secure_key.blob`" @u
    checkresponse 1 "Key error"
    dmsetup create encrootfs --table "0 $(blockdev --getsz ${root}) crypt aes-xts-plain64 :64:secure:rootfs 0 ${root} 0"
    checkresponse 1 "Fileencryption error"
    mount /dev/dm-0 /newroot
    checkresponse 1 "encrypted mount error"
    umount /mnt_secrets
else
    # Net is not encrypted
    mount ${root} /newroot
fi

mount --move /dev /newroot/dev
umount /sys /proc
exec switch_root /newroot ${init:-/sbin/init}
