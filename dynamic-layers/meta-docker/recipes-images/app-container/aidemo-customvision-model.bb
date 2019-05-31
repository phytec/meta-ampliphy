SUMMARY = "A minimal container image just providing an application with its dependencies"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

# supported by poky and systemd-nspawn
#IMAGE_FSTYPES = "container"
# requires docker runtime and meta-docker for
# the docker image type
IMAGE_CLASSES += "image_type_docker"
IMAGE_FSTYPES = "docker"

# set a meaningful name  and tag for the docker output image
DOCKER_IMAGE_TAG = "0.5.0"
DOCKER_IMAGE_NAME_EXPORT ?= "aidemo-customvision-model:${DOCKER_IMAGE_TAG}"

inherit image

IMAGE_TYPEDEP_container += "ext4"

IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""
NO_RECOMMENDATIONS = "1"

IMAGE_INSTALL += "\
        busybox \
        base-passwd \
        netbase \
        predict \
"
