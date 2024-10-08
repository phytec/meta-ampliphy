#
# This include file is a selector for the linux-mainline recipe from
# https://github.com/betafive/meta-linux-mainline
#

DISTRO:append = "-linux-mainline"
DISTRO_NAME:append = " using linux-mainline"

PREFERRED_PROVIDER_virtual/kernel = "linux-mainline"
