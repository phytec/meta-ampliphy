require recipes-images/images/phytec-headless-image.bb

SUMMARY = "This image is designed to be a development image for HTML5 applications" 

IMAGE_FEATURES += "ssh-server-openssh"

#some space for application content
IMAGE_ROOTFS_EXTRA_SPACE = "524288"

LICENSE = "MIT"

IMAGE_INSTALL += "\
    packagegroup-base \
    \
    qtwebbrowser \
    nodejs \
    nodejs-npm \
    mraa \
    mraa-utils \
    node-mraa \
    upm \
    node-upm \
    \
    html5demo \
"
