require recipes-images/images/phytec-headless-image.bb

SUMMARY =  "This image is designed to show development of camera and \
            imaging applications with openCV and QT."

IMAGE_FEATURES += "splash ssh-server-openssh hwcodecs qtcreator-debug"
IMAGE_FEATURES += "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', '', bb.utils.contains('DISTRO_FEATURES', 'x11', 'x11-base', '', d), d)}\
"

LICENSE = "MIT"

inherit populate_sdk_qt5

IMAGE_INSTALL += "\
    packagegroup-base \
    \
    packagegroup-gstreamer \
    packagegroup-camera \
    \
    qt5-opengles2-test \
    phytec-qtdemo \
    opencv \
    gstreamer1.0-plugins-bad-opencv \
    python-phycam-margin-analysis \
    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'qtwayland qtwayland-plugins weston weston-init', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'weston-xwayland', '', d)} \
"

IMAGE_INSTALL_remove_mx6ul = "\
    qt5-opengles2-test \
"
