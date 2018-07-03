#!/bin/sh

MOUNT=/media/$1

NUMRAUCM=$(find ${MOUNT}/*.raucb -maxdepth 0 | wc -l)

[ "$NUMRAUCM" -eq 0 ] && echo "${MOUNT}*.raucb not found" && exit
[ "$NUMRAUCM" -ne 1 ] && echo "more than one ${MOUNT}/*.raucb" && exit

rauc install $MOUNT/*.raucb
if [ "$?" -ne 0 ]; then
	echo "Failed to install RAUC bundle."
else
	echo "Update successful."
fi
exit $?
