PACKAGECONFIG = "${@base_contains('DISTRO_FEATURES', 'pulseaudio', 'pulseaudio', '', d)} ${@base_contains('DISTRO_FEATURES', 'alsa', 'alsa', '', d)}"
