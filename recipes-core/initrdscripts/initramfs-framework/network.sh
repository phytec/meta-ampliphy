#!/bin/sh

network_enabled() {
	return $(ip link ls up dev eth0 | wc -l)
}

network_run() {
	ip addr add 127.0.0.1/8 dev lo brd + scope host
	ip link set dev lo up

	ip addr add 192.168.3.11/255.255.255.0 broadcast 192.168.3.255 dev eth0 scope global
	ip link set dev eth0 up
	dhcpcd -n eth0
}
