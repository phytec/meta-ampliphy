SUMMARY = "Phytec's Azure IoT Edge image"
DESCRIPTIION = "We use chrony to sync the time for the gateway and to the nodes"
LICENSE = "MIT"
inherit core-image

IMAGE_INSTALL = " \
    packagegroup-machine-base \
    packagegroup-core-boot \
    packagegroup-update \
    openssh \
    chrony \
    chronyc \
    iproute2 \
    \
    docker \
    iotedge-cli \
    iotedge-daemon \
    aikit-docker-images \
    \
    weston \
    weston-init \
"
