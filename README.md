meta-ampliphy
=============

ampliPHY is PHYTEC's integration and verification distribution based on
Poky. We build our development kits and hardware development images
using this layer. We also stage some of our upstream and customer
project's work here. You might find some useful stuff.
Notable supported features are:

 * hw verification tools for fully functional CI testing
 * systemd/networkd/pspslash/weston/wayland setup
 * secure boot and secure provisioning for production
 * rauc remote A/B system update client integration
 * partup board factory flashing
 * docker/podman/container runtime

Support
=======

If you experience any problem with this software, please contact our
<support@phytec.de> or the maintainer directly.
Please try to do the following first:

* look in the
  [Yocto Project Bugzilla](http://bugzilla.yoctoproject.org/)
  to see if a problem has already been reported
* look through recent entries of the
  [Yocto mailing list archives](https://lists.yoctoproject.org/pipermail/yocto/)
  to see if other people have run into similar
  problems or had similar questions answered.

License
=======

This layer is distributed under the MIT license if not noted otherwise.
This includes all recipes, configuration files and meta data created by
PHYTEC. Source code included in the tree is distributed under the
license stated in the corresponding recipe or as mentioned in the code.
There is some work of others companies included or referenced.
Attribution is kept as required. The recipe meta data is mostly MIT,
if not noted otherwise. The binaries and code compiled for the target
rootfs is distributed under the vendors license. The licenses are
provided in the /licenses subdirectory to be collected by bitbake.
Please be aware that you need to agree to the specific vendor licenses
if you use the proprietary code for your product.

Maintainer
==========

M:  Stefan Müller-Klieser <s.mueller-klieser@phytec.de>
M:  Norbert Wesp <n.wesp@phytec.de>

Dependencies
============

This layer depends on Openembedded-Core, Bitbake, meta-phytec and others
depending on the branch.
