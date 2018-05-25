require recipes-images/images/phytec-qt5demo-image.bb

SUMMARY =  "This image is designed to show development of OpenCV and Qt."

IMAGE_INSTALL += "\
    opencv \
    gstreamer1.0-plugins-bad-opencv \
"
