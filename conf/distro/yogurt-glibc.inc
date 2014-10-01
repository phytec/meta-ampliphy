PNBLACKLIST[libiconv] = "the glibc provided iconv library is used"

TARGET_OS = "linux"
TARGET_OS .= "${@['','-gnueabi'][bb.data.getVar('TARGET_ARCH',d,1) in ['arm', 'armeb']]}"

# perl has some problems, see http://bugs.openembedded.net/show_bug.cgi?id=1616
# [23:00] oxo: glibc (any version) on sparc does not like (repeat me) "-Os"

TARGET_LINK_HASH_STYLE = "${@['-Wl,--hash-style=gnu',''][bb.data.getVar('TARGET_ARCH',d,1) in ['mips', 'mipsel', 'mips64', 'mips64el']]}"
