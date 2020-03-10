openssl-ca.sh
=============

This scripts creates one main-ca (root-ca).
The main ca is the base of the intermedite certificates for bootloader
and FIT-Image.
                    main-ca
                        |
                        |
                -----------------
                |               |
            nxp_habv4_pki       fit
                |
            -------------
            |           |
            SRK1        SRKn
            |
        ---------
        |       |
        CSF     IMG

nxp_habv4_pki = for bootloader on a NXP i.MX with HABV4 (e.g. i.MX6)
fit = is for FIT Image Container with kernel, devicetree and optional ramdisk

In this version rauc has his own root-ca, which is not derived from the
main-ca. The reason is the Certificate Chain check in rauc.
