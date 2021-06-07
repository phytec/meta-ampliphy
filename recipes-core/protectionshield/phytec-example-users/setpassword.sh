#!/bin/sh
SetRootPassword=yes
#userlist=($(awk -F":" '($2 == "!" || $2 == "") {print $1}' /etc/shadow))
userlist=($(awk -F":" '{ if (substr($2,1,1) ~ /^[*! ]/ ) print $1}' /etc/shadow))
mac=$(cat /sys/class/net/eth0/address | tr -d ':' | tr '[a-z]' '[A-Z]')
for name in "${userlist[@]}"
do
    uid=($(awk -v name=${name} -F":" '{ if ($1 == name) print $3}' /etc/passwd))
    if [ $uid -eq 0 -a ${SetRootPassword} == "yes" ] || [ $uid -gt 1000 -a $uid -le 10000 ]; then
        /usr/sbin/usermod --password $(echo "${name}${mac}" | openssl passwd -1 -stdin) ${name}
    fi
done

exit 0
