PACKAGECONFIG:remove = "${@bb.utils.contains('MACHINE_FEATURES', 'gpu', '', 'vulkan', d)}"
