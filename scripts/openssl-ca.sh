#!/bin/bash
# Script for creation of Main CA, SecureBoot Keys, rauc keys
# requirements: NXP CST Tool 3.0.1 or 3.1.0

if [ "$1" == '' ] ||  [ "$1" == '-h' ]; then
    echo "no parameter, please use the following"
    echo "-h List of all parameter"
    echo "-m Create a new main Certificate Autority"
    echo "-a Create Bootloader and FIT-Image Keys"
    echo "-b Create Bootloader Keys"
    echo "-s Sign Bootloader Keys with CST"
    echo "-f Create FIT-Image Key"
    echo "-r Create rauc keys"
    echo "-k Keytype (rsa or ecc, default rsa)"
    echo "-C Set path to CA"
    echo "-P Set path for initial folder"
    echo
fi

ORG="PHYTEC Messtechnik GmbH"
CA="PHYTEC BSP CA"

MAINCAPATH=""
MAINCADIR="main-ca"
MAINCAKEYS="keys"

BOOTLOADERKEY=0
FITIMAGEKEY=0
BOOTLOADERDIR="nxp_habv4_pki"
BOOTLOODERPATH=""
FITDIR="fit"
FITIMAGEPATH=""

RAUCKEY=0
RAUCDIR="rauc"
RAUCPATH=""

KEYTYPE="rsa"

DO_CSTSIGN=false

BASECA="$(pwd)/openssl-ca"
BASEDIR="$(pwd)"

DO_CREATEMAINCA=false

while getopts ':abfkmrsC:P:' OPTION ; do
    case "$OPTION" in
    b) BOOTLOADERKEY=1;;
    f) FITIMAGEKEY=1;;
    a) BOOTLOADERKEY=1
       FITIMAGEKEY=1;;
    m) DO_CREATEMAINCA=true;;
    s) DO_CSTSIGN=true;;
    k) KEYTYPE=$OPTARG;;
    r) RAUCKEY=1;;
    C) BASECA=$OPTARG;;
    P) BASEDIR=$OPTARG;;
        *) printf "Unknown parameter\n"
    esac
done

#set -xe
MAINCAPATH="$BASECA"/"$MAINCADIR"
if $DO_CREATEMAINCA; then
    printf "Creation of the Main CA for Bootloader, FIT-Image and\n"
    printf "rauc bundle Signning\n"
    printf "The Main CA based on RSA4096\n"

    if [ -e $MAINCAPATH ]; then
        echo "Main CA RSA Path $MAINCAPATH already exists"
        exit 1
    fi 2>&1

    if [ ! -e $MAINCAPATH ]; then
        mkdir -p $MAINCAPATH/keys
    fi
    if [ ! -f $MAINCAPATH/keys/key_pass.txt ]; then
        printf "No pass phrase for protecting the Main CA private keys\n"
        printf "Please put a pass phrase (store it in the key_pass.txt): \b"
        read existing_passphrase
        echo $existing_passphrase > $MAINCAPATH/keys/key_pass.txt
        echo $existing_passphrase >> $MAINCAPATH/keys/key_pass.txt
    fi

    mkdir -p ${MAINCAPATH}/private
    touch ${MAINCAPATH}/index.txt
    echo 1000 > ${MAINCAPATH}/serial
cat > $MAINCAPATH/openssl.cnf <<EOF
[ default ]
ca                 = x_ca                    # CA name
dir                = .                       # Top dir

[ca]
default_ca         = x_ca

[x_ca]
dir                = .
database           = \$dir/index.txt
new_certs_dir      = \$dir
serial             = \$dir/serial
private_key        = \$dir/private/mainca-rsa.key.pem
certificate        = mainca-rsa.crt.pem
default_days       = 32850
default_md         = sha256
policy             = policy_any
x509_extensions    = v3_inter

[ req ]
prompt             = no
encrypt_key        = no

# base request
distinguished_name = req_distinguished_name


[ policy_any ]
commonName          = supplied
organizationName    = match
localityName        = match
countryName         = match
stateOrProvinceName = match
description         = optional

[ v3_inter ]
# Extensions for a typical Inter CA.
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical, CA:true,pathlen:0
keyUsage               = critical, digitalSignature, cRLSign, keyCertSign
EOF

    openssl req -newkey rsa:4096 -passout file:$MAINCAPATH/keys/key_pass.txt \
        -keyout ${MAINCAPATH}/private/mainca-rsa.key.pem \
        -out ${MAINCAPATH}/mainca-rsa.crt.pem -days 36500 -x509 \
        -config $BASEDIR/scripts/mainca_creation.cnf
    if [ -f ${MAINCAPATH}/mainca-rsa.crt.pem ]; then
        echo "Main CA ${MAINCAPATH}/mainca-rsa.crt successful created"
    fi
fi

if $DO_CSTSIGN; then
    echo "Sign CA $BASEDIR"
    if [ ! -f $BASEDIR/hab4_pki_tree.sh ]; then
        printf "hab4_pki_tree do not exist\n"
        printf "Please download the NXP Code Signing Tools (CST)\n"
        printf "from the https://www.nxp.com/webapp/sps/download/license.jsp?colCode=IMX_CST_TOOL\n"
        echo "and copy the hab4_pki_tree.sh from release\keys to the $(pwd)"
        exit 1
    fi >&2

    if [ ! -f $BASEDIR/srktool ]
    then
        printf "srktool do not exist\n"
        printf "Please download the NXP Code Signing Tools (CST)\n"
        printf "from the https://www.nxp.com/webapp/sps/download/license.jsp?colCode=IMX_CST_TOOL\n"
        echo "and copy the srktool from release\keys to the $(pwd)"
        exit 1
    fi >&2

    [ $BOOTLOADERKEY -eq 1 ] || {
        printf " -s requires -b\n"
        exit 1
    } >&2
fi

if [ $BOOTLOADERKEY -eq 1 ]
then
    BOOTLOODERPATH="$BASECA"/"$BOOTLOADERDIR"
    if [ -e $BOOTLOODERPATH ]; then
        echo "Bootloader Path $BOOTLOODERPATH already exists"
        exit 1
    fi 2>&1

    mkdir -p $BOOTLOODERPATH/{ca,crts,keys}
    touch $BOOTLOODERPATH/keys/index.txt

    # Check that the file "serial" is present, if not create it:
    if [ ! -f $BOOTLOODERPATH/keys/serial ]
    then
        printf "serial: a positive 32-bit number that uniquely identifies\n"
        printf "the certificate per certification authority e.g. 12345678 ?:\b"
        read existing_serial
        echo $existing_serial > $BOOTLOODERPATH/keys/serial
    fi

    # Check that the file "serial" is present, if not create it:
    if [ ! -f $BOOTLOODERPATH/keys/key_pass.txt ]
    then
        if [ ! -f $MAINCAPATH/keys/key_pass.txt ]; then
            printf "No pass phrase for protecting the HAB code private keys\n"
            printf "Please put a pass phrase (store it in the key_pass.txt): \b"
            read existing_passphrase
            echo $existing_passphrase > $BOOTLOODERPATH/keys/key_pass.txt
            echo $existing_passphrase >> $BOOTLOODERPATH/keys/key_pass.txt
        else
            cp $MAINCAPATH/keys/key_pass.txt $BOOTLOODERPATH/keys/key_pass.txt
        fi
    fi

cat > $BOOTLOODERPATH/ca/v3_ca.cnf <<EOF
# PKIX-conformant extensions on CA certificates

# PKIX recommendation.
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer:always

# PKIX requires basicConstraints to be critical on CA certs (sec 4.2.1.9)
basicConstraints = critical,CA:true

# PKIX requires keyUsage present with keyCertSign on CA certs (sec 4.2.1.3)
keyUsage = keyCertSign
EOF

cat > $BOOTLOODERPATH/ca/v3_usr.cnf <<EOF
# Standard openssl extensions on user certificates

# These extensions are added when 'ca' signs a request.

# This goes against PKIX guidelines but some CAs do it and some software
# requires this to avoid interpreting an end user certificate as a CA.

basicConstraints = CA:FALSE

# Here are some examples of the usage of nsCertType. If it is omitted
# the certificate can be used for anything *except* object signing.

# This is OK for an SSL server.
# nsCertType = server

# For an object signing certificate this would be used.
# nsCertType = objsign

# For normal client use this is typical
# nsCertType = client, email

# and for everything including object signing:
# nsCertType = client, email, objsign

# This is typical in keyUsage for a client certificate.
# keyUsage = nonRepudiation, digitalSignature, keyEncipherment

# This will be displayed in Netscape's comment listbox.
nsComment = "OpenSSL Generated Certificate"

# PKIX recommendations harmless if included in all certificates.
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer

# This stuff is for subjectAltName and issuerAltname.
# Import the email address.
# subjectAltName = email:copy
# An alternative to produce certificates that aren't
# deprecated according to PKIX.
# subjectAltName = email:move

# Copy subject details
# issuerAltName = issuer:copy

#nsCaRevocationUrl = http://www.domain.dom/ca-crl.pem
#nsBaseUrl
#nsRevocationUrl
#nsRenewalUrl
#nsCaPolicyUrl
#nsSslServerName

EOF

cat > $BOOTLOODERPATH/ca/openssl.cnf <<EOF
# Establish working directory.

[ ca ]
default_ca             = CA_default

[ CA_default ]
dir                    = .
serial                 = \$dir/serial
database               = \$dir/index.txt
new_certs_dir          = \$dir
certificate            = \$dir/cacert.pem
private_key            = \$dir/ca_key.pem
default_days           = 3650
default_md             = sha256
preserve               = no
email_in_dn            = no
nameopt                = default_ca
certopt                = default_ca
policy                 = policy_match
x509_extensions        = openssl_usr_cert

[ policy_match ]
countryName            = optional
stateOrProvinceName    = optional
organizationName       = optional
organizationalUnitName = optional
commonName             = supplied
emailAddress           = optional

[ req ]
default_bits           = 2048                # Size of keys
default_keyfile        = key.pem             # name of generated keys
default_md             = sha256              # message digest algorithm
string_mask            = nombstr             # permitted characters
distinguished_name     = req_distinguished_name
#req_extensions        = v3_req
x509_extensions        = v3_ca

# Passwords for private keys if not present they will be prompted for
# input_password  = secret
# output_password = secret

[ req_distinguished_name ]
# Variable name         Prompt string
#-------------------    ------------------------------------------
countryName             = Country Name (2 letter code)
countryName_default     = US
commonName              = Common Name (hostname, IP, or your name)
commonName_max          = 64

#0.organizationName     = Organization Name (company)
#organizationalUnitName = Organizational Unit Name (department, division)
#emailAddress           = Email Address
#emailAddress_max       = 40
#localityName           = Locality Name (city, district)
#stateOrProvinceName    = State or Province Name (full name)
#countryName_min        = 2
#countryName_max        = 2

# Default values for the above, for consistency and less typing.
# Variable name                Value
#--------------------------    ------------------------------
0.organizationName_default     = My Company
localityName_default           = My Town
stateOrProvinceName_default    = State or Providence

[ v3_usr ]
# Standard openssl extensions on user certificates
# These extensions are added when 'ca' signs a request.
# This goes against PKIX guidelines but some CAs do it and some software
# requires this to avoid interpreting an end user certificate as a CA.
basicConstraints = CA:FALSE

# PKIX recommendations harmless if included in all certificates.
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer

[ v3_ca ]
# PKIX-conformant extensions on CA certificates
# PKIX recommendation.
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer:always

# PKIX requires basicConstraints to be critical on CA certs (sec 4.2.1.9)
basicConstraints = critical,CA:true

# PKIX requires keyUsage present with keyCertSign on CA certs (sec 4.2.1.3)
keyUsage = keyCertSign

[ v3_req ]
basicConstraints     = CA:FALSE
subjectKeyIdentifier = hash
EOF

    export OPENSSL_CONF=$BOOTLOODERPATH/ca/openssl.cnf
fi

if $DO_CSTSIGN; then
    cd $BOOTLOODERPATH/keys

    #check, if main ca exists and note about using it
    if [ -f ${MAINCAPATH}/mainca-rsa.crt.pem ]; then
        echo " Main ca exist, please use existing CA in SRK creation Tool with"
        echo "CA key name: ${MAINCAPATH}/private/mainca-rsa.key"
        echo "CA certificate name:  ${MAINCAPATH}/mainca-rsa.crt"
    fi
    echo "Do you want start the SRK creation with hab4_pki_tree.sh (y/n)"
    read start_srkcreation
    if [ $start_srkcreation = "y" ]; then
        $BASEDIR/hab4_pki_tree.sh

        cd $BOOTLOODERPATH/crts

        kl=$(find SRK1_sha256_*.pem | awk '{ split($0,a,"_"); print a[3]'})

         $BASEDIR/srktool -h 4 -t SRK_1_2_3_4_table.bin \
             -e SRK_1_2_3_4_fuse.bin \
             -d sha256 -c ./SRK1_sha256_${kl}_65537_v3_ca_crt.pem,\
             ./SRK2_sha256_${kl}_65537_v3_ca_crt.pem,\
             ./SRK3_sha256_${kl}_65537_v3_ca_crt.pem,\
             ./SRK4_sha256_${kl}_65537_v3_ca_crt.pem -f 1

        #check
        if [ ! -f SRK_1_2_3_4_fuse.bin ]
        then
            printf "Error: Creation of SRK fuse failed\n"
            exit 1
        fi >&2
    else
        exit 1
    fi >&2
fi

if [ $FITIMAGEKEY -eq 1 ]
then
    echo "Creation of Signing Keys for FIT-Image"
    FITIMAGEPATH="$BASECA"/"$FITDIR"

    printf "Enter key length in bits for PKI tree: "
    read kl
    # Confirm that a valid key length has been entered
    case $kl in
        2048) ;;
        4096) ;;
        *)
            echo "Invalid key length. Supported key lengths: 2048, 4096" >&2
            exit 1 ;;
    esac
    cd $BASECA
    mkdir -p $FITIMAGEPATH
    cd $FITIMAGEPATH
    if [ -f FIT-${kl}.key ]; then
        echo "FIT Key  FIT-${kl}.key exists"
        exit 1
    fi >&2

    openssl genpkey -algorithm RSA -out FIT-${kl}.key \
        -pkeyopt rsa_keygen_bits:$kl -pkeyopt rsa_keygen_pubexp:65537
    if [ -f ${MAINCAPATH}/mainca-rsa.crt.pem ]; then
        echo "Main RSA CA ${MAINCAPATH}/mainca-rsa.crt  exist and will be used"
        openssl req -config $BASEDIR/scripts/fit_creation.cnf \
            -new -sha256 -key $FITIMAGEPATH/FIT-${kl}.key \
            -out $FITIMAGEPATH/FIT-${kl}.csr
        cd $MAINCAPATH
        openssl ca -config openssl.cnf -batch \
            -passin file:${MAINCAPATH}/keys/key_pass.txt \
            -in $FITIMAGEPATH/FIT-${kl}.csr \
            -out $FITIMAGEPATH/FIT-${kl}.crt
        if [ $? -ne 0 ]; then
            printf "FIT Certification Creation failed !!\n"
            printf "TXT_DB Error = CN of FIT exist in the main ca db\n"
            printf "Please change the CN in fit_creation.cnf\n"
        fi
    else
        printf "Self signed Certificate for the FIT-Image will be created \n"
        openssl req -batch -new -x509 -key FIT-${kl}.key -out FIT-${kl}.crt
    fi
fi

if [ $RAUCKEY -eq 1 ]; then
    echo "Creation of Signing Keys for rauc bundles"
    RAUCPATH="$BASECA"/"$RAUCDIR"
    if [ -e $RAUCPATH ]; then
        echo "RAUC-Image Path $RAUCPATH already exists"
        exit 1
    fi >&2
    printf "Enter key length in bits for rauc PKI tree: "
    read kl
    # Confirm that a valid key length has been entered
    case $kl in
        2048) ;;
        4096) ;;
    *)
        echo "Invalid key length. Supported key lengths: 2048, 4096" >&2
        exit 1 ;;
    esac
    cd $BASECA
    mkdir -p $RAUCPATH
    mkdir -p $RAUCPATH/{private,certs}
    touch $RAUCPATH/index.txt
    echo 01 > $RAUCPATH/serial
cat > $RAUCPATH/openssl.cnf <<EOF
[ ca ]
default_ca        = CA_default               # The default ca section

[ CA_default ]

dir               = .                        # top dir
database          = \$dir/index.txt          # index file.
new_certs_dir     = \$dir/certs              # new certs dir

certificate       = \$dir/ca.cert.pem        # The CA cert
serial            = \$dir/serial             # serial no file
private_key       = \$dir/private/ca.key.pem # CA private key
RANDFILE          = \$dir/private/.rand      # random number file

default_startdate = 19700101000000Z
default_enddate   = 99991231235959Z
default_crl_days  = 30                       # how long before next CRL
default_md        = sha256                   # md to use

policy            = policy_any               # default policy
email_in_dn       = no                       # Don't add the email into cert DN

name_opt          = ca_default               # Subject name display option
cert_opt          = ca_default               # Certificate display option
copy_extensions   = none                     # Don't copy extensions from request

[ policy_any ]
organizationName = match
commonName       = supplied

[ req ]
default_bits       = 2048
distinguished_name = req_distinguished_name
x509_extensions    = v3_leaf
encrypt_key        = no
default_md         = sha256

[ req_distinguished_name ]
commonName     = Phytec Yocto BSP Builder
commonName_max = 64

[ v3_ca ]

subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer:always
basicConstraints       = CA:TRUE

[ v3_inter ]

subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer:always
basicConstraints       = CA:TRUE,pathlen:0

[ v3_leaf ]

subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer:always
basicConstraints       = CA:FALSE
EOF

    cd $RAUCPATH
    openssl genpkey -algorithm RSA -out private/ca.key.pem \
        -pkeyopt rsa_keygen_bits:$kl -pkeyopt rsa_keygen_pubexp:65537

    #if [ -f ${MAINCAPATH}/mainca-rsa.crt.pem ]; then
    #    echo "Main RSA CA ${MAINCAPATH}/mainca-rsa.crt  exist and will be used"
    #    openssl req -config $BASEDIR/scripts/rauc_creation.cnf -new \
    #    -sha256 -key $RAUCPATH/private/ca.key.pem -out $RAUCPATH/ca.csr.pem
    #    cd $MAINCAPATH
    #    openssl ca -config openssl.cnf -batch \
    #    -passin file:${MAINCAPATH}/keys/key_pass.txt \
    #    -in $RAUCPATH/ca.csr.pem -out $RAUCPATH/ca.cert.pem
    #else
        cd $RAUCPATH
        printf "Self signed Certificate for the rauc bundle intependent\n"
        printf "from the main ca will be created \n"
        openssl req -batch -config $BASEDIR/scripts/rauc_creation.cnf \
            -new -x509 -extensions v3_ca -key private/ca.key.pem \
            -out ca.cert.pem -days 65535
    #fi
    echo "Development Signing Keys 1"
    cd $RAUCPATH
    openssl genpkey -algorithm RSA -out private/development-1.key.pem \
        -pkeyopt rsa_keygen_bits:$kl \
        -pkeyopt rsa_keygen_pubexp:65537
    openssl req -new -sha256 -key $RAUCPATH/private/development-1.key.pem \
        -out $RAUCPATH/development-1.csr.pem \
        -subj "/O=$ORG/CN=$ORG Development-1"

    openssl ca -config openssl.cnf -batch -extensions v3_leaf \
        -in development-1.csr.pem -out development-1.cert.pem
fi
