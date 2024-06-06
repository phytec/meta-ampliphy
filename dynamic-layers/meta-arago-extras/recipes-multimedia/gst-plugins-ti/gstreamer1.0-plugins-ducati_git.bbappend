# gstreamer1.0-plugins-ducati use FetchContent to download more sources during
# do_configure. Until this is resolved we need to allow network operations.
do_configure[network] = "1"
