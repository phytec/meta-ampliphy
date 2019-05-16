#!/bin/bash
# Creation Script for Signing Key
# requirements: NXP CST Tool 3.0.1 or 3.1.0

if [ "$1" == '' ]; then
    echo "no parameter, please use the following\n"
    echo "-h List of all parameter\n"
    echo "-a Create Bootloader and FIT-Image Keys\n"
    echo "-b Create Bootloader Keys\n"
    echo "-f Create FIT-Image Key\n"
    echo
fi

BOOTLOADERKEY=0
FITIMAGEKEY=0
BOOTLOADERDIR="bootloader"
BOOTLOODERPATH=""
FITDIR="fit"
FITIMAGEPATH=""

while getopts ':abf:' OPTION ; do
    case "$OPTION" in
        b) BOOTLOADERKEY=1;;
        f) FITIMAGEKEY=1;;
        a) BOOTLOADERKEY=1
           FITIMAGEKEY=1;;
        *) echo "Unknown parameter"
    esac
done

#set -xe

BASECA="$(pwd)/secureboot-ca"
BASEDIR="$(pwd)"

if [ $BOOTLOADERKEY -eq 1 ]
then
    BOOTLOODERPATH="$BASECA"/"$BOOTLOADERDIR"
    if [ -e $BOOTLOODERPATH ]; then
        echo "Bootloader Path $BOOTLOODERPATH already exists"
        exit 1
    fi

    if [ ! -f hab4_pki_tree.sh ]
    then
        printf "hab4_pki_tree do not exist\n"
        printf "Please download the NXP Code Signing Tools (CST)\n"
        printf "from the https://www.nxp.com/webapp/sps/download/license.jsp?colCode=IMX_CST_TOOL\n"
        printf "and copy the hab4_pki_tree.sh from release\keys to the script folder of this yocto layer\n"
        exit 1
    fi

    if [ ! -f srktool ]
    then
        printf "srktool do not exist\n"
        printf "Please download the NXP Code Signing Tools (CST)\n"
        printf "from the https://www.nxp.com/webapp/sps/download/license.jsp?colCode=IMX_CST_TOOL\n"
        printf "and copy the hab4_pki_tree.sh from release\keys to the script folder of this yocto layer\n"
        exit 1
    fi

    mkdir -p $BOOTLOODERPATH/{ca,crts,keys}
    touch $BOOTLOODERPATH/keys/index.txt

    # Check that the file "serial" is present, if not create it:
    if [ ! -f $BOOTLOODERPATH/keys/serial ]
    then
        printf "If you already have a certificate that you want to use as CA,\n"
        printf "skip this step. Otherwise, you can create a plain text file called serial.txt now\n"
        printf "Do you want use an existing certificate as CA (y/n)?:  \b"
        read existing_ca
        if [ $existing_ca = "n" ]
        then
            printf "serial: a positive 32-bit number that uniquely identifies the certificate per certification authority e.g. 12345678 ?:  \b"
            read existing_serial
            echo $existing_serial > $BOOTLOODERPATH/keys/serial
        fi
    fi

    # Check that the file "serial" is present, if not create it:
    if [ ! -f $BOOTLOODERPATH/keys/key_pass.txt ]
    then
        printf "No pass phrase for protecting the HAB code signing private keys\n"
        printf "Please put a pass phrase (store it in the key_pass.txt): \b"
        read existing_passphrase
        echo $existing_passphrase > $BOOTLOODERPATH/keys/key_pass.txt
        echo $existing_passphrase >> $BOOTLOODERPATH/keys/key_pass.txt
    fi

cat > $BOOTLOODERPATH/ca/v3_ca.cnf <<EOF
# PKIX-conformant extensions on CA certificates

# PKIX recommendation.
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always

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

basicConstraints=CA:FALSE

# Here are some examples of the usage of nsCertType. If it is omitted
# the certificate can be used for anything *except* object signing.

# This is OK for an SSL server.
# nsCertType			= server

# For an object signing certificate this would be used.
# nsCertType = objsign

# For normal client use this is typical
# nsCertType = client, email

# and for everything including object signing:
# nsCertType = client, email, objsign

# This is typical in keyUsage for a client certificate.
# keyUsage = nonRepudiation, digitalSignature, keyEncipherment

# This will be displayed in Netscape's comment listbox.
nsComment			= "OpenSSL Generated Certificate"

# PKIX recommendations harmless if included in all certificates.
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer

# This stuff is for subjectAltName and issuerAltname.
# Import the email address.
# subjectAltName=email:copy
# An alternative to produce certificates that aren't
# deprecated according to PKIX.
# subjectAltName=email:move

# Copy subject details
# issuerAltName=issuer:copy

#nsCaRevocationUrl		= http://www.domain.dom/ca-crl.pem
#nsBaseUrl
#nsRevocationUrl
#nsRenewalUrl
#nsCaPolicyUrl
#nsSslServerName

EOF

cat > $BOOTLOODERPATH/ca/openssl.cnf <<EOF
# Establish working directory.



[ ca ]
default_ca				= CA_default

[ CA_default ]
dir					= .
serial					= \$dir/serial
database				= \$dir/index.txt
new_certs_dir				= \$dir
certificate				= \$dir/cacert.pem
private_key				= \$dir/ca_key.pem
default_days				= 3650
default_md				= sha256
preserve				= no
email_in_dn				= no
nameopt					= default_ca
certopt					= default_ca
policy					= policy_match
x509_extensions	                        = openssl_usr_cert     # Default extensions to add to the cert

[ policy_match ]
countryName				= optional
stateOrProvinceName			= optional
organizationName			= optional
organizationalUnitName			= optional
commonName				= supplied
emailAddress				= optional

[ req ]
default_bits				= 2048			# Size of keys
default_keyfile				= key.pem		# name of generated keys
default_md				= sha256		# message digest algorithm
string_mask				= nombstr		# permitted characters
distinguished_name			= req_distinguished_name
#req_extensions				= v3_req                # omit - openssl doesn't copy req extension
x509_extensions	                        = v3_ca                 # The extentions to add to the self signed cert

# Passwords for private keys if not present they will be prompted for
# input_password = secret
# output_password = secret

[ req_distinguished_name ]
# Variable name				Prompt string
#-------------------------	  ----------------------------------
countryName				= Country Name (2 letter code)
countryName_default			= US
commonName				= Common Name (hostname, IP, or your name)
commonName_max				= 64

#0.organizationName			= Organization Name (company)
#organizationalUnitName			= Organizational Unit Name (department, division)
#emailAddress				= Email Address
#emailAddress_max			= 40
#localityName				= Locality Name (city, district)
#stateOrProvinceName			= State or Province Name (full name)
#countryName_min				= 2
#countryName_max				= 2

# Default values for the above, for consistency and less typing.
# Variable name				Value
#------------------------	  ------------------------------
0.organizationName_default		= My Company
localityName_default			= My Town
stateOrProvinceName_default		= State or Providence

[ v3_usr ]
# Standard openssl extensions on user certificates
# These extensions are added when 'ca' signs a request.
# This goes against PKIX guidelines but some CAs do it and some software
# requires this to avoid interpreting an end user certificate as a CA.
basicConstraints=CA:FALSE

# PKIX recommendations harmless if included in all certificates.
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer

[ v3_ca ]
# PKIX-conformant extensions on CA certificates
# PKIX recommendation.
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always

# PKIX requires basicConstraints to be critical on CA certs (sec 4.2.1.9)
basicConstraints = critical,CA:true

# PKIX requires keyUsage present with keyCertSign on CA certs (sec 4.2.1.3)
keyUsage = keyCertSign

[ v3_req ]
basicConstraints			= CA:FALSE
subjectKeyIdentifier			= hash
EOF

    export OPENSSL_CONF=$BOOTLOODERPATH/ca/openssl.cnf
    cd $BOOTLOODERPATH/keys

    echo "Development CA"
    $BASEDIR/hab4_pki_tree.sh

    cd $BOOTLOODERPATH/crts

    kl=$(find SRK1_sha256_*.pem | awk '{ split($0,a,"_"); print a[3]'})

    $BASEDIR/srktool -h 4 -t SRK_1_2_3_4_table.bin -e SRK_1_2_3_4_fuse.bin -d sha256 -c ./SRK1_sha256_${kl}_65537_v3_ca_crt.pem,./SRK2_sha256_${kl}_65537_v3_ca_crt.pem,./SRK3_sha256_${kl}_65537_v3_ca_crt.pem,./SRK4_sha256_${kl}_65537_v3_ca_crt.pem -f 1

    #check
    if [ ! -f SRK_1_2_3_4_fuse.bin ]
    then
        printf "Error: Creation of SRK fuse failed\n"
        exit 1
    fi
fi

if [ $FITIMAGEKEY -eq 1 ]
then
    echo "Creation of Signing Keys for FIT-Image\n"
    FITIMAGEPATH="$BASECA"/"$FITDIR"
    if [ -e $FITIMAGEPATH ]; then
        echo "FIT-Image Path $FITIMAGEPATH already exists"
        exit 1
    fi

    printf "Enter key length in bits for PKI tree:  \b"
    read kl
    # Confirm that a valid key length has been entered
    case $kl in
        1024) ;;
        2048) ;;
        3072) ;;
        4096) ;;
        *)
            echo Invalid key length. Supported key lengths: 1024, 2048, 3072, 4096
            exit 1 ;;
    esac
    cd $BASECA
    mkdir -p $FITIMAGEPATH
    cd $FITIMAGEPATH
    openssl genrsa -F4 -out dev.key $kl
    openssl genpkey -algorithm RSA -out dev.key -pkeyopt rsa_keygen_bits:$kl -pkeyopt rsa_keygen_pubexp:65537
    openssl req -batch -new -x509 -key dev.key -out dev.crt
fi
