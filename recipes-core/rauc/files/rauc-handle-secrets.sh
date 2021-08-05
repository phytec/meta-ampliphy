#!/bin/sh

set -e
trap end EXIT
end() {
    result=$?
    if [ "$result" -ne 0 ]; then
        exit $result
    fi
}


MODE=0
[ $# -ne 1 ] && exit 2
while getopts br opt 2>/dev/null
do
    case $opt in
        b) MODE=1;;
        r) MODE=2;;
        ?) exit 3
    esac
done

[ $MODE -eq 0 ] && exit 4

for arg in $(cat /proc/cmdline); do
     case "${arg}" in
        root=*) eval ${arg};;
    esac
done

mkdir -p /tmp/backup_secrets
mkdir -p /tmp/mnt_secrets
if echo "$root" | grep -q "mmc"; then
    #mmc or emmc => key example are in the first partition
    mount ${root%?}1 /tmp/mnt_secrets

    if [ $MODE -eq 1 ]; then
        # Backup Mode
        if [ -d /tmp/mnt_secrets/secrets ]; then
            cp -r /tmp/mnt_secrets/secrets /tmp/backup_secrets
        fi
    elif [ $MODE -eq 2 ]; then
        # Restore Mode
        if [ -d /tmp/backup_secrets/secrets ]; then
            mv -n /tmp/backup_secrets/secrets /tmp/mnt_secrets
        fi
    fi
    umount /tmp/mnt_secrets
fi
