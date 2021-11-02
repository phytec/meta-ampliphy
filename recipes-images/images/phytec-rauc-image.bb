require recipes-images/images/phytec-headless-image.bb

SUMMARY = "Phytec's headless image utilizing RAUC"
DESCRIPTION = "no graphics support in this image"
LICENSE = "MIT"

IMAGE_INSTALL += " \
    packagegroup-update \
"

WKS_FILES_mx6 = "imx6-rauc-sdimage.wks"
WKS_FILES_mx6ul = "imx6-rauc-sdimage.wks"
WKS_FILES_mx8m = "imx8m-rauc-sdimage.wks"
