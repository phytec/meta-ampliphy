# gstreamer1.0-plugins-hevc use FetchContent to download more sources during
# do_configure. Until this is resolved we need to allow network operations.
do_configure[network] = "1"

FILESEXTRAPATHS:prepend := "${THISDIR}/gstreamer1.0-plugins-hevc:"

SRC_URI:append = " \
    file://0001-Switch-submodule-common-to-github.patch \
"
