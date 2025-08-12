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

Variable Glossary
-----------------

ampliPHY provides bitbake variables below:

* `DISTRO_FEATURES`
  Following `DISTRO_FEATURES` are supported to configure ampliPHY. Those are
  features extending pokys feature set:
  - `secureboot`
  - `protectionshield`
  - `hardening`
  - `securestorage`
  - `kernelmodsign`
  - `rauc-appfs`

* `MACHINE_FEATURES`
  Following `MACHINE_FEATURES` are used in this layer to enable extra features
  in the BSP if enabled:
  - `can`, `fan`, `pcie`, and `resistivetouch` install additional software tools
    to make use of the hardware features.

* `BB_PHY_BUILDTYPE` - Shell environment variable to specify when a
  build-execution shall be treated as an official release build.

  The `DISTRO_VERSION` can have the appendix '-devel'. That '-devel' marker
  indicates to the user that the respective build and its output (e.g. a
  target-image) were not part of any official release procedure.
  In contrast to a release-build, such a development-build can usually have
  significant restrictions, as e.g.:
  - might contain intermediate development-changes
  - functionality might not be (fully) tested
  - parts of the code-base might be located in restricted repositories without
    any public access
    Attention: That could lead to OSS license violations when sharing those binaries
    with external parties!

  You can read a '-devel' marked version (e.g. 'PD24.1.0-devel') as:
    "based on PD24.1.0, but contains developer-changes on top"

  Use the environment variable `BB_PHY_BUILDTYPE` to influence the behavior of
  development-build marker '-devel'. When `BB_PHY_BUILDTYPE` was set to
  'RELEASE' before calling bitbake, the build-execution is treated as
  release-build and '-devel' will not be appended. Instead, if
  `BB_PHY_BUILDTYPE` is unset or empty '-devel' will be appended to the
  `DISTRO_VERSION`.

     Example to start a "release build":
     ```bash
        host $ export BB_PHY_BUILDTYPE=RELEASE
        host $ export BB_ENV_PASSTHROUGH_ADDITIONS="$BB_ENV_PASSTHROUGH_ADDITIONS BB_PHY_BUILDTYPE"
        host $ bitbake phytec-headless-image
     ```

  ATTENTION: One who executes a release build with `BB_PHY_BUILDTYPE=RELEASE`
  must carefully assure that all requirements for an official release-build are
  met (e.g. tagged code-base in public repositories, maybe disabled
  sstate-cache, ...).

  NOTE: Packages that make use of the variable `DISTRO_VERSION` (e.g.
        ampliphy-version, base-files, kernel, u-boot) differ in sstate for a
        release-build and a development-build. However, as long as a build-
        pipeline that feeds an sstate-mirror executes development-builds, this
        does not negatively affect the sstate-mirror use or the developers
        build time.

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
