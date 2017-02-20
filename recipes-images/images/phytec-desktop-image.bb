require recipes-images/images/phytec-headless-image.bb

SUMMARY =  "This image is designed to be a development image for complex \
            multi application scenarios under weston or for desktop use."

IMAGE_FEATURES += "splash package-management ssh-server-openssh hwcodecs"

LICENSE = "MIT"

inherit distro_features_check populate_sdk_qt5

REQUIRED_DISTRO_FEATURES = "wayland"

IMAGE_INSTALL += "\
    weston \
    weston-init \
    packagegroup-base \
    \
    packagegroup-gstreamer \
    \
    qtwayland \
    \
    qt5-opengles2-test \
    phytec-qtdemo \
"
