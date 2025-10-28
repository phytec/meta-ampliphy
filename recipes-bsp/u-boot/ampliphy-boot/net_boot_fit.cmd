test -n ${fit_addr_r} && env set loadaddr ${fit_addr_r}
if itest.s ${ip_dyn} == 0 || itest.s ${ip_dyn} == no || itest.s ${ip_dyn} == false; then
	env set nfsip ${ipaddr}:${serverip}::${netmask}::eth0:on;
	env set net_fetch_cmd tftp;
else
	env set nfsip dhcp;
	env set net_fetch_cmd dhcp;
fi;
env set bootargs "console=${console} earlycon=${earlycon} root=/dev/nfs ip=${nfsip} rw nfsroot=${serverip}:${nfsroot},vers=4,tcp ${optargs}"
${net_fetch_cmd} ${loadaddr} fitImage

# Load overlays
fdt address ${loadaddr};
fdt get value fit_default_conf /configurations/ default;
env set fit_overlay_conf "#${fit_default_conf}";
for overlay in ${overlays}; do
  env set fit_overlay_conf "${fit_overlay_conf}#conf-${overlay}";
done;

bootm ${loadaddr}${fit_overlay_conf}
