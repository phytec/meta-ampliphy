# remove x264 from default PACKAGECONFIG,
# because of commercial licensing
PACKAGECONFIG_remove = "x264"

# to be sure, we do not use any components with patents,
# we also disable all individual component options
# Individual components are:
#   encoders, decoders, hwaccels, muxers, demuxers,
#   parsers, bitstream filters, protocols, input devices,
#   output devices, devices, filters
EXTRA_OECONF_append = " \
--disable-everything \
--enable-zlib \
--enable-decoders \
--disable-decoder=mp3 \
--disable-decoder=aac \
--disable-decoder=h264 \
--disable-decoder=rpza \
--disable-decoder=mpeg4 \
--disable-decoder=mpeg2video \
"

# only with openssl set manually in PACKAGECONFIG,
# codecs that require --enable-nonfree will be used
#
# FFmpeg itself is under LGPLv2.1+ and GPLv2+
LICENSE_FLAGS_WHITELIST_append = " commercial_ffmpeg"
