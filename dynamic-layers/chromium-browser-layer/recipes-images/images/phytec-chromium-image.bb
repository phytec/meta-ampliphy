require recipes-images/images/phytec-headless-image.bb

SUMMARY = "This image is designed to start the chromium browser on wayland \
           during start up."

LICENSE = "MIT"

IMAGE_FEATURES += "\
     splash \
     ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston', '', d)} \
"

IMAGE_INSTALL += "\
    packagegroup-base \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston weston-init', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'weston-xwayland', '', d)} \
    chromium-ozone-wayland \
    chromium-service \
"
