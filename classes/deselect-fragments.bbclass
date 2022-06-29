# This is for recipes which support config merging for Kconfig-based software
# such as the linux kernel, busybox, barebox and u-boot etc.

# Creates a string containing file:// URIs to deselection fragment.
# This string is to be appened to SRC_URI

# mfeatures_checklist: A list of MACHINE_FEATURE entries a deselection fragment should
# be added for if the entry is missing in the MACHINE_FEATURES variable
# dselectionstr: A deselection string such as "xen bluetooth", probably you want
# to pass the value of a variable here. For every entry, the corresponding
# deselect fragment must exist, e. g. deselect-xen.cfg
def create_deselection_list(mfeatures_checklist : list, deselectionstr, d):
    result = ""
    deselected_features = []
    # First, deselect by absent MACHINE_FEATURES
    for feature in mfeatures_checklist:
        deselect = bb.utils.contains('MACHINE_FEATURES', feature, '', feature, d)
        if deselect != '':
            deselected_features.append(deselect)

    # Secondly, deselect by deselectionstr
    deselected_features.extend(deselectionstr.split())

    for feature in set(deselected_features):
        result += " file://deselect-{0}.cfg ".format(feature)
    return result

