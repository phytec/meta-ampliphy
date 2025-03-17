#
# A script to boot Ampliphy from a SPI NOR Flash device
#

test -n ${fdtfile} || env set fdtfile oftree

env set bootargs "console=${console} earlycon=${earlycon} ${optargs}"

sf probe
sf read ${kernel_addr_r} ${spi_image_addr} ${size_kern}
sf read ${fdt_addr_r} ${spi_fdt_addr} ${size_fdt}
sf read ${ramdisk_addr_r} ${spi_ramdisk_addr} ${size_fs}
booti ${kernel_addr_r} ${ramdisk_addr_r}:0x${size_fs} ${fdt_addr_r}
