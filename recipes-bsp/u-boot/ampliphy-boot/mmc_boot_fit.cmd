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
env set filesize 0
size ${devtype} ${devnum}:${distro_bootpart} ${overlaysenvfile}
if test ${filesize} != 0; then
	run mmc_load_overlaysenv
	env import -t ${loadaddr} ${filesize} overlays
fi

load ${devtype} ${devnum}:${distro_bootpart} ${loadaddr} fitImage

# Load overlays
fdt address ${loadaddr};
fdt get value fit_default_conf /configurations/ default;
env set fit_overlay_conf "#${fit_default_conf}";
for overlay in ${overlays}; do
	env set fit_overlay_conf "${fit_overlay_conf}#conf-${overlay}";
done;

bootm ${loadaddr}${fit_overlay_conf}
