#
# A script to boot Ampliphy from a MMC device using fitImage
#

test -n ${mmcroot} || env set mmcroot 2

env set bootargs "console=${console} earlycon=${earlycon} root=/dev/mmcblk${devnum}p${mmcroot} rootwait rw ${optargs}"

mmc dev ${devnum};
load mmc ${mmcdev}:${mmcpart} ${addr_fit} fitImage
bootm ${addr_fit}
