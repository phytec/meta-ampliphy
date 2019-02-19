require recipes-images/images/phytec-headless-image.bb

SUMMARY =  "This image is designed to show development of a Qt application \
            running on the eglfs single application backend."

IMAGE_FEATURES += "splash ssh-server-openssh hwcodecs qtcreator-debug"

LICENSE = "MIT"

inherit distro_features_check populate_sdk_qt5

CONFLICT_DISTRO_FEATURES = "x11 wayland"

IMAGE_INSTALL += "\
    packagegroup-base \
    \
    packagegroup-gstreamer \
    \
    qt5-opengles2-test \
    phytec-qtdemo \
"

IMAGE_INSTALL_remove_mx6ul = "\
    qt5-opengles2-test \
"
