# we only use and recommend patent free codecs, so we can remove the
# commercial flag from the recipe
# recommended patent free formats are:
# video container: Matroska, WebM
# video format: Theora, VP8
# audio container: OGG, flac
# audio format: Vorbis, flac
LICENSE_FLAGS = ""
# whitelisting in combination with --disable-everything does not work
# so we disable the most common and "patent offensive" codecs manually
LIBAV_EXTRA_CONFIGURE_COMMON_ARG_append = " \
--enable-zlib \
--disable-encoders --disable-muxers \
--disable-decoder=mp3 \
--disable-decoder=aac \
--disable-decoder=h264 \
--disable-decoder=rpza \
--disable-decoder=mpeg4 \
--disable-decoder=mpeg2video \
"
