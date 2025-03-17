#
# A script to boot Ampliphy from Ethernet
#

test -n ${fdtfile} || env set fdtfile oftree

env set autoload no
env set bootargs "console=${console} root=/dev/nfs ip=dhcp rw nfsroot=${serverip}:${nfsroot},vers=4,tcp ${optargs}"
dhcp
tftp ${kernel_addr_r} ${serverip}:/Image
tftp ${fdt_addr_r} ${serverip}:/${fdtfile}
booti ${kernel_addr_r} - ${fdt_addr_r}
