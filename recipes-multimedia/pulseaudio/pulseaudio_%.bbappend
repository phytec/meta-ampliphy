PACKAGECONFIG:append = " autospawn-for-root"

PACKAGECONFIG[oss-output] = "-Doss-output=enabled,-Doss-output=disabled,"

# WORKAROUND: Remove exceptions from poky/meta/conf/distro/include/time64.inc
# until this is fixed in upstream. For now only possible with build flags
# "-Doss-output=disabled" (see PACKAGECONFIG above) as otherwise build fails.
# URL: https://gitlab.freedesktop.org/pulseaudio/pulseaudio/-/issues/3770
GLIBC_64BIT_TIME_FLAGS:pn-pulseaudio = " -D_TIME_BITS=64 -D_FILE_OFFSET_BITS=64"
INSANE_SKIP:remove:pn-pulseaudio = "32bit-time"
