DEPENDS:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'opengl', '', 'virtual/libgl', d)}"
