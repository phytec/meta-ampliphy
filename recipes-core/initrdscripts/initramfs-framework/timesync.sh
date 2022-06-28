#!/bin/sh

timesync_enabled() {
	return 0
}

timesync_run() {
	/usr/sbin/chronyd
}
