if itest.s ${devtype} != mmc; then
	echo "ERROR: Invalid boot script for devtype ${devtype}, expected mmc! Exiting..."
	exit
fi

test -n ${distro_rootpart} || env set distro_rootpart 2
test -n ${fit_addr_r} && env set loadaddr ${fit_addr_r}
env set bootargs "console=${console} earlycon=${earlycon} root=/dev/mapper/mmcblk${devnum}p${distro_rootpart} ${raucargs} rootwait rw ${optargs}"

load ${devtype} ${devnum}:${distro_bootpart} ${loadaddr} fitImage

# Load default configuration
fdt address ${loadaddr};
fdt get value fit_default_conf /configurations/ default;

if test -n ${fit_overlay_conf}; then
	bootm ${loadaddr}#${fit_default_conf}${fit_extensions}#${fit_overlay_conf}
else
	bootm ${loadaddr}#${fit_default_conf}${fit_extensions}
fi
reset
