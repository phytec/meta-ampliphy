#!/bin/sh

opteeclient_enabled() {
	tee-supplicant -h &>/dev/null
	[ $? -ne 0 ] && return 1
	[ "$(pidof tee-supplicant)" != "" ] && return 1
	return 0
}

opteeclient_run() {
	[ "$(pidof tee-supplicant)" == "" ] && tee-supplicant &
}
