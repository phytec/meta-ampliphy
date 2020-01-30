# Generate pkgconfig file opencv.pc
# See https://github.com/opencv/opencv/issues/13154
EXTRA_OECMAKE_append = " -DOPENCV_GENERATE_PKGCONFIG=ON"
