test -n ${distro_rootpart} || env set distro_rootpart 2
env set bootargs "console=${console} earlycon=${earlycon} root=/dev/mmcblk${devnum}p${distro_rootpart} ${raucargs} rootwait rw ${optargs}"
env set mmc_load_overlay 'load ${devtype} ${devnum}:${distro_bootpart} ${fdtoverlay_addr_r} ${overlay}'
load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} Image
load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${fdtfile}

# Load overlays
fdt address ${fdt_addr_r}
for overlay in ${overlays}; do
  echo Applying overlay: ${overlay};
  if run mmc_load_overlay; then
    fdt resize ${filesize}
    fdt apply ${fdtoverlay_addr_r}
  fi
done

booti ${kernel_addr_r} - ${fdt_addr_r}
