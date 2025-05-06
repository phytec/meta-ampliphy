test -n ${mmcroot} || env set mmcroot 2
test -n ${fit_addr_r} && env set loadaddr ${fit_addr_r}
env set bootargs "console=${console} earlycon=${earlycon} root=/dev/mmcblk${devnum}p${mmcroot} ${raucargs} rootwait rw ${optargs}"
load ${devtype} ${devnum}:${distro_bootpart} ${loadaddr} fitImage
bootm ${loadaddr}
