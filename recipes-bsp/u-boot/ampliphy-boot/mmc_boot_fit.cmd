if itest.s ${devtype} != mmc; then
	echo "ERROR: Invalid boot script for devtype ${devtype}, expected mmc! Exiting..."
	exit
fi

test -n ${distro_rootpart} || env set distro_rootpart 2
test -n ${fit_addr_r} && env set loadaddr ${fit_addr_r}
test -n ${overlaysenvfile} || env set overlaysenvfile overlays.txt
env set bootargs "console=${console} earlycon=${earlycon} root=/dev/mmcblk${devnum}p${distro_rootpart} ${raucargs} rootwait rw ${optargs}"
env set mmc_load_overlaysenv 'load ${devtype} ${devnum}:${distro_bootpart} ${loadaddr} ${overlaysenvfile}'

# Load additional file containing default overlays
if test -e ${devtype} ${devnum}:${distro_bootpart} ${overlaysenvfile}; then
	run mmc_load_overlaysenv
	env import -t ${loadaddr} ${filesize} fit_overlay_conf
fi

load ${devtype} ${devnum}:${distro_bootpart} ${loadaddr} fitImage

# Load default configuration
fdt address ${loadaddr};
fdt get value fit_default_conf /configurations/ default;

if test -n ${fit_overlay_conf}; then
	bootm ${loadaddr}#${fit_default_conf}#${fit_overlay_conf}
else
	bootm ${loadaddr}#${fit_default_conf}
fi
