test -n ${mmcroot} || env set mmcroot 2
env set bootargs "console=${console} earlycon=${earlycon} root=/dev/mmcblk${devnum}p${mmcroot} ${raucargs} rootwait rw ${optargs}"
load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} Image
load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${fdtfile}
booti ${kernel_addr_r} - ${fdt_addr_r}
