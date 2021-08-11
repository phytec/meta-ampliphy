require recipes-images/images/phytec-headless-image.bb

SUMMARY =  "This image is designed to show development of a Qt application \
            running on the eglfs single application backend."

IMAGE_FEATURES += "splash ssh-server-openssh hwcodecs qtcreator-debug"

LICENSE = "MIT"

inherit populate_sdk_qt5

IMAGE_INSTALL += "\
    packagegroup-base \
    \
    packagegroup-gstreamer \
    \
    qt5-opengles2-test \
    phytec-qtdemo \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'qtwayland qtwayland-plugins weston weston-init', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'weston-xwayland', '', d)} \
"

IMAGE_INSTALL:remove:mx6ul = "\
    qt5-opengles2-test \
"
