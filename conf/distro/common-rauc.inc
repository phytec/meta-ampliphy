# Add distro feature rauc. The OVERRIDE must be named differently, as there is
# already a package with the same name.
DISTRO_FEATURES:append = " rauc"
DISTROOVERRIDES:append = ":update"

# Reactivate sanity checks from meta-rauc
SKIP_META_RAUC_FEATURE_CHECK = "0"
