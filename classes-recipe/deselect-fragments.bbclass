# This is for recipes which support config merging for Kconfig-based software
# such as the linux kernel, busybox, barebox and u-boot etc.

# Creates a string containing file:// URIs to deselection fragment.
# This string is to be appened to SRC_URI

# features: Check the feature e. g. xen, if is not in the MACHINE_FEATURES or
# is in the KERNEL_FEATURES_DESELECT, then deselect the feature.
# For every feature, a corresponding deselect fragment must exist,
# e. g. deselect-xen.cfg
def contain_deselect(feature, d):
    deselected_features = []
    deselect = bb.utils.contains('MACHINE_FEATURES', feature, '', feature, d)
    if deselect != '':
        return "file://deselect-{0}.cfg ".format(feature)

    # Secondly, deselect by deselectionstr
    deselectionstr = d.getVar('KERNEL_FEATURES_DESELECT')
    if deselectionstr is not None:
        deselected_features.extend(deselectionstr.split())

    for desfeature in set(deselected_features):
        if desfeature == feature:
            return "file://deselect-{0}.cfg ".format(feature)
    return ''
