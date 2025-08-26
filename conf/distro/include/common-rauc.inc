# Add distro feature rauc. The OVERRIDE must be named differently, as there is
# already a package with the same name.
DISTRO_FEATURES:append = " rauc"
DISTROOVERRIDES:append = ":update"

# Reactivate sanity checks from meta-rauc
SKIP_META_RAUC_FEATURE_CHECK = "0"

# Align rootfs to 4 kiB blocks to support "block-hash-index" adapative updates
IMAGE_ROOTFS_ALIGNMENT = "4"

# Activate redundant application slots
#DISTRO_FEATURES += "rauc-appfs"
#DISTROOVERRIDES:append = ":rauc-appfs"
