PACKAGECONFIG += "ftdi-eeprom"
PACKAGECONFIG[ftdi-eeprom] = "-DFTDI_EEPROM=on,-DFTDI_EEPROM=off,confuse"
PACKAGES =+ "ftdi-eeprom"
FILES:ftdi-eeprom += "${bindir}/ftdi_eeprom"
