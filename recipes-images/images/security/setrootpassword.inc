inherit extrausers

# encrypted password for root
PROTECTION_SHIELD_ROOT_ENCRYPTED_PASSWORD ??= 'PI9ZxRHV.sgB6'

_ROOT_USER = ''
_ROOT_USER:shieldlow = 'usermod -p ${PROTECTION_SHIELD_ROOT_ENCRYPTED_PASSWORD} root'
#no login available
_ROOT_USER:shieldhigh = 'usermod -L root'
EXTRA_USERS_PARAMS += "\
   ${@bb.utils.contains('DISTRO_FEATURES','protectionshield', '${_ROOT_USER}', '',d)} \
"

IMAGE_FEATURES:shieldlow += "allow-root-login"
IMAGE_FEATURES:shieldmedium += "allow-root-login"
