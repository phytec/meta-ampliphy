#!/bin/sh

smartcard_enabled() {
	pcscd -v &>/dev/null
	[ $? -ne 0 ] && return 1
	[ "$(pidof pcscd)" != "" ] && return 1
	return 0
}

smartcard_run() {
	[ "$(pidof pcscd)" == "" ] && pcscd -f &
}
