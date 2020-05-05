# Copyright (C) 2020 Maik Otto <m.otto@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)
inherit extrausers

PROTECTION_SHIELD_ROOT_PASSWORD ??= 'root'

_ROOT_USER = ''
_ROOT_USER_shieldlow = 'usermod -P ${PROTECTION_SHIELD_ROOT_PASSWORD} root'
_ROOT_USER_shieldmedium = 'usermod -P ${PROTECTION_SHIELD_ROOT_PASSWORD} root'
#no login available
_ROOT_USER_shieldhigh = 'usermod -L root'
EXTRA_USERS_PARAMS += "\
   ${@bb.utils.contains('DISTRO_FEATURES','protectionshield', '${_ROOT_USER}', '',d)} \
"
