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

mkdir -p /proc /sys /dev /secrets
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# Set kernel console loglevel
LOGLEVEL="$(sysctl -n kernel.printk)"
sysctl -q -w kernel.printk=4

for arg in $(cat /proc/cmdline); do
	case "${arg}" in
		rescue=1|root=*) eval ${arg};;
	esac
done

# Translate "PARTUUID=..." to real device
root="$(findfs ${root})"

# go to login, when requested
[ -n "${rescue}" ] && do_login

mkdir -p /newroot
if echo "$root" | grep -q "mmc"; then
    #mmc or emmc => key example is in partition 3
    secret=${root%?}3
    mount ${secret} /secrets

    test -f /secrets/secure_key.blob
    checkresponse 0 "No secure_key.blob for Fileencryption in folder /secrets"
    keyctl add secure rootfs  "load `cat /secrets/secure_key.blob`" @u
    checkresponse 1 "Key error"
    dmsetup create encrootfs --table "0 $(blockdev --getsz ${root}) crypt aes-xts-plain64 :64:secure:rootfs 0 ${root} 0"
    checkresponse 1 "Fileencryption error"
    mount /dev/dm-0 /newroot
    checkresponse 1 "encrypted mount error"
else
    #Nand or net is not encrypted
    mount ${root} /newroot
fi

mount --move /dev /newroot/dev
umount /sys /proc
exec switch_root /newroot ${init:-/sbin/init}
