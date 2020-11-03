# Copyright (C) 2020 Maik Otto <m.otto@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)


FITIMAGE_SIGN ??= "false"
FITIMAGE_SIGN[type] = "boolean"

_FITIMAGE_TO_WIC = ""
_FITIMAGE_TO_WIC_secureboot = 'phytec-simple-fitimage:do_deploy'

do_image_wic[depends] += "\
    ${@bb.utils.contains('FITIMAGE_SIGN','true','${_FITIMAGE_TO_WIC}','', d)}"
