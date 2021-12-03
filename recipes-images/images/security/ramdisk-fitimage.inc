# Copyright (C) 2020 Maik Otto <m.otto@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

do_image_wic[depends] += "\
    ${@bb.utils.contains('DISTRO_FEATURES','secureboot','phytec-secureboot-ramdisk-fitimage:do_deploy','', d)}"
