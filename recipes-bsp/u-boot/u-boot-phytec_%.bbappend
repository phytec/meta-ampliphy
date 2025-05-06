STANDARD_BOOT_ENV = ""
STANDARD_BOOT_ENV:k3 = "\\"'\
script_offset_f=0x700000\0\
script_size_f=0x2000\0\
boot_script_dhcp=net_boot_fit.scr.uimg\0\
fitimage_offset_f=0x740000\0\
'\\""

# Extend the default environment by passing CFG_EXTRA_ENV_SETTINGS via
# user specific CPPFLAGS -> KCPPFLAGS.
# From the u-boot README about CFG_EXTRA_ENV_SETTINGS:
#   Warning: This method is based on knowledge about the internal format
#   how the environment is stored by the U-Boot code. This is NOT an
#   official, exported interface! Although it is unlikely that this
#   format will change soon, there is no guarantee either.
export KCPPFLAGS = " -DCFG_EXTRA_ENV_SETTINGS=${STANDARD_BOOT_ENV}"
