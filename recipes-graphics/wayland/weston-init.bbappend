FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += "file://weston.ini"

# HACK: NXP's meta-imx (mickledore-6.1.36-2.1.0) weston-init.bbappend fails in
# case weston.sh file is not present. This happens because weston.sh is not
# installed by meta-freescale in case DISTROOVERRIDES doesn't contain "fsl" or
# "fslc" strings. Obviously, we use ampliphy DISTRO and thus DISTROOVERRIDES
# does not not contain aforementioned string, hence build fails. Resort to this
# workaround until this is fixed in upstream.
# PR URL: https://github.com/nxp-imx/meta-imx/pull/20
do_install:prepend:mx93-nxp-bsp() {
    install -d ${D}${sysconfdir}/profile.d
    touch ${D}${sysconfdir}/profile.d/weston.sh
}
