require recipes-images/images/phytec-headless-image.bb

DESCRIPTION = "Adds native compiler toolchain to the headless-image"

IMAGE_FEATURES += "tools-sdk dev-pkgs tools-debug eclipse-debug tools-profile tools-testapps debug-tweaks"

IMAGE_INSTALL += "kernel-dev"
