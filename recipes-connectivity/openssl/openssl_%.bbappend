# Use hardware cryptography accelerators
PACKAGECONFIG:append:am57xx = " cryptodev-linux"
PACKAGECONFIG:append:mx6-generic-bsp = " cryptodev-linux"
PACKAGECONFIG:append:mx6ul-generic-bsp = " cryptodev-linux"
