SUMMARY =  "This image is designed to be a deployment image for HTML5 applications"

LICENSE = "MIT"

IMAGE_INSTALL += "\
    packagegroup-base \
    \
    html5demo \
    \
    qtwebbrowser \
    nodejs \
    mraa \
    node-mraa \
    node-upm \
"
