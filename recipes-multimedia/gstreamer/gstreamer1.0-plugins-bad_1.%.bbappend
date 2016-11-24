FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

PACKAGECONFIG[kms] = "--enable-kms,--disable-kms,libdrm"

PACKAGECONFIG_append = " kms"

# $ ls -1 gstreamer1.0-plugins-bad | sort | xargs -I test echo "    file://test \\"
SRC_URI += " \
    file://0001-kmssink-add-plugin-and-sink-element.patch \
    file://0002-kmssink-calculate-display-ratio.patch \
    file://0003-kmssink-add-dmabuf-support.patch \
    file://0004-kmssink-wait-for-page-flip-or-vblank.patch \
    file://0005-kmssink-keep-last-rendered-buffer-in-memory.patch \
    file://0006-kmssink-enable-Y42B-planar-YUV-4-2-2-format.patch \
    file://0007-kmssink-enable-NV16-chroma-interleaved-YUV-4-2-2-for.patch \
    file://0008-kmssink-enable-UYVY-YUY2-and-YVYU-interleaved-YUV-4-.patch \
    file://0009-kmssink-add-sync-support-for-secondary-pipes.patch \
    file://0010-kmssink-chain-up-finalize-method.patch \
    file://0011-kmssink-use-trace-level-for-buffer-render-log.patch \
    file://0012-kmssink-frame-copy-log-in-performance-category.patch \
    file://0013-kmsbufferpool-error-only-if-no-allocator.patch \
    file://0014-kmssink-add-a-plane-id-property.patch \
    file://0015-kmssink-fallback-to-universal-planes-if-no-overlay-p.patch \
    file://0016-kmssink-Fix-offsets-handling.patch \
    file://0017-kmssink-override-stride-if-defined-in-driver.patch \
    file://0018-kmssink-Fix-selection-of-source-region.patch \
    file://0019-kmssink-Scale-up-to-the-screen-dimension.patch \
    file://0020-kms-rename-variable-used.patch \
    file://0021-kmssink-remove-custom-gst_kms_sink_get_times.patch \
    file://0022-kmssink-do-not-get-kms-bo-pitch-for-planar-formats.patch \
    file://0023-kmssink-Enable-in-meson-build.patch \
    file://0024-kmssink-Trivial-naming-fix-in-meson-for-consistency.patch \
    file://0025-kmssink-allow-to-disable-DRM-plane-hardware-scaling.patch \
"
