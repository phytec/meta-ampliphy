require phytec-hwbringup-image.bb

DESCRIPTION = "Adds native compiler toolchain to the hwbringup-image"

IMAGE_FEATURES += "tools-sdk dev-pkgs tools-debug eclipse-debug tools-profile tools-testapps debug-tweaks"

IMAGE_INSTALL += "kernel-dev"
