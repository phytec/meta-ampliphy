if itest.s ${devtype} != ethernet; then
	echo "ERROR: Invalid boot script for devtype ${devtype}, expected ethernet! Exiting..."
	exit
fi

test -n ${fit_addr_r} && env set loadaddr ${fit_addr_r}
test -n ${overlaysenvfile} || env set overlaysenvfile overlays.txt
if itest.s ${ip_dyn} == 0 || itest.s ${ip_dyn} == no || itest.s ${ip_dyn} == false; then
	env set nfsip ${ipaddr}:${serverip}::${netmask}::eth0:on;
	env set net_fetch_cmd tftp;
else
	env set nfsip dhcp;
	env set net_fetch_cmd dhcp;
fi;
env set bootargs "console=${console} earlycon=${earlycon} root=/dev/nfs ip=${nfsip} rw nfsroot=${serverip}:${nfsroot},vers=4,tcp ${optargs}"
env set net_load_overlaysenv "'${net_fetch_cmd}' ${loadaddr} ${overlaysenvfile}"

# Load additional file containing default overlays
if run net_load_overlaysenv; then
	env import -t ${loadaddr} ${filesize} fit_overlay_conf;
fi;

${net_fetch_cmd} ${loadaddr} fitImage

# Load default configuration
fdt address ${loadaddr};
fdt get value fit_default_conf /configurations/ default;

if test -n ${fit_overlay_conf}; then
	bootm ${loadaddr}#${fit_default_conf}#${fit_overlay_conf}
else
	bootm ${loadaddr}#${fit_default_conf}
fi
