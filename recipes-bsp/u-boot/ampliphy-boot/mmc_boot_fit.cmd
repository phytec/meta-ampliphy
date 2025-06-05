test -n ${mmcroot} || env set mmcroot 2
test -n ${distro_rootpart} && env set mmcroot ${distro_rootpart}
test -n ${fit_addr_r} && env set loadaddr ${fit_addr_r}
env set bootargs "console=${console} earlycon=${earlycon} root=/dev/mmcblk${devnum}p${mmcroot} ${raucargs} rootwait rw ${optargs}"
load ${devtype} ${devnum}:${distro_bootpart} ${loadaddr} fitImage

# Load overlays
fdt address ${loadaddr};
fdt get value fit_default_conf /configurations/ default;
env set fit_overlay_conf "#${fit_default_conf}";
for overlay in ${overlays}; do
  env set fit_overlay_conf "${fit_overlay_conf}#conf-${overlay}";
done;

bootm ${loadaddr}${fit_overlay_conf}
