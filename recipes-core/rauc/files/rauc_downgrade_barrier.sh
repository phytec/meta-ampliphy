#!/bin/sh

VERSION_FILE=/etc/rauc/downgrade_barrier_version
MANIFEST_FILE=${RAUC_UPDATE_SOURCE}/manifest.raucm

[ ! -f ${VERSION_FILE} ] && exit 1
[ ! -f ${MANIFEST_FILE} ] && exit 2

VERSION=`cat ${VERSION_FILE} | cut -d 'r' -f 2`
BUNDLE_VERSION=`grep "version" -rI ${MANIFEST_FILE} | cut -d 'r' -f 3`

# check from empty or unset variables
[ -z "${VERSION}" ] && exit 3
[ -z "${BUNDLE_VERSION}" ] && exit 4

# developer mode, allow all updates if version is r0
[ ${VERSION} -eq 0 ] && exit 0

# downgrade barrier
if [ ${VERSION} -gt ${BUNDLE_VERSION} ]; then
	echo "Downgrade barrier blocked rauc update! CODE5\n"
else
	exit 0
fi
exit 5
