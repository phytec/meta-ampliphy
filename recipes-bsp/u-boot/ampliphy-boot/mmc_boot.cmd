#
# A script to boot Ampliphy from a MMC device
#

test -n ${mmcroot} || env set mmcroot 2
test -n ${fdtfile} || env set fdtfile oftree

env set bootargs "console=${console} earlycon=${earlycon} root=/dev/mmcblk${devnum}p${mmcroot} rootwait rw ${optargs}"

mmc dev ${devnum};
load mmc ${mmcdev}:${distro_bootpart} ${kernel_addr_r} Image
load mmc ${mmcdev}:${distro_bootpart} ${fdt_addr_r} ${fdtfile}

fdt address ${fdt_addr_r};
for overlay in ${overlays};
do;
  if load mmc ${devnum}:${mmcroot} ${fdtoverlay_addr_r} ${overlay}; then
    fdt resize ${filesize};
    fdt apply ${fdtoverlay_addr_r};
  fi;
done;

booti ${kernel_addr_r} - ${fdt_addr_r}
