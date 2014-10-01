SUMMARY = "Yogurt QT5"
DESCRIPTION = "An image to test QT5 with Yocto."
LICENSE = "MIT"
IMAGE_LINGUAS = " "

inherit core-image distro_features_check

#build barebox too
IMAGE_RDEPENDS += "barebox barebox-ipl"

IMAGE_INSTALL = " \
    packagegroup-base \
    packagegroup-core-boot \
    ${@base_contains('MACHINE_FEATURES','sgx','packagegroup-ti-graphics','',d)} \
    tslib-conf \
    tslib-calibrate \
    tslib-tests \
    qtbase \
    qtbase-plugins \
    qtdeclarative-plugins \
    qtlocation-plugins \
    qtmultimedia-plugins \
    qt3d \
    qtquick1 \
    qtbase-tools \
    qt5everywheredemo \
    cinematicexperience \
"

#hotfix dependcies correction of qt5everywheredemo
IMAGE_INSTALL += "qtmultimedia qtsvg"

export IMAGE_BASENAME = "yogurt-qt5"


