# There is already a package '${PN}-blkid'
PACKAGES =+ "${PN}-lsblk ${PN}-blkdiscard"
FILES_${PN}-lsblk = "${bindir}/lsblk"
FILES_${PN}-blkdiscard= "${sbindir}/blkdiscard"
