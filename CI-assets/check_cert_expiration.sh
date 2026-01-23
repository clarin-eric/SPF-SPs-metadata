#!/bin/bash

DAYS=30
REQUIRED_BITS=3072

parse_date() {
    if date --version >/dev/null 2>&1; then 
        # GNU date (Linux)
        date -d "$1" +%s
    else
        # BSD date (macOS) 
        date -j -f "%b %d %H:%M:%S %Y %Z" "$1" +%s
    fi
}

verify_key_size() {
    CERT="$1"
    FILE="$2"
    KEY_BITS=$(printf "%s" "$CERT" \
        | openssl x509 -noout -text -in /dev/stdin \
        | awk -F'[()]' '/Public-Key/ {print $2}' \
        | awk '{print $1}')

    if [ -z "$KEY_BITS" ]; then
        echo "Could not determine key size in $FILE"
        return 1
    fi

    if (( KEY_BITS < REQUIRED_BITS )); then
        echo -e "\t❌ Key size too small: ${KEY_BITS} bits (minimum is ${REQUIRED_BITS})"
    else
        echo -e "\t🔐 Key size OK: ${KEY_BITS} bits"
    fi

}

verify_expire_date() {
    CERT="$1"
    FILE="$2"
    # Extract expiration date (in seconds since epoch)
    ENDDATE=$(printf "%s" "${CERT}" \
        | openssl x509 -enddate -noout -in /dev/stdin \
        | cut -d= -f2)

    if [ -z "$ENDDATE" ]; then
        echo "Could not parse certificate in ${FILE}"
        return 1
    fi

    EXPIRY_EPOCH=$(parse_date "$ENDDATE")

    if [ -z "$EXPIRY_EPOCH" ]; then
        echo "Could not parse expiry date in $FILE"
        return 1
    fi


    NOW_EPOCH=$(date +%s)
    THIRTY_DAYS=$(( DAYS * 24 * 3600 ))
    WARNING_EPOCH=$(( NOW_EPOCH + THIRTY_DAYS ))

    if (( EXPIRY_EPOCH < NOW_EPOCH )); then
        echo -e "\t❌ Certificate has already expired."
    elif (( EXPIRY_EPOCH < WARNING_EPOCH )); then
        echo -e "\t⚠️ Certificate will expire within $DAYS days."
    else
        echo -e "\t✅ Certificate is valid for more than $DAYS days."
    fi
}

for md_file in ../metadata/*; do
    echo "Checking file: ${md_file}"
    RAW_CERT=$(xmllint --xpath "string(//*[local-name()='X509Certificate'])" "$md_file" \
        | tr -d ' \t\n\r')

    if [ -z "$RAW_CERT" ]; then
        echo "No certificate found in $md_file"
        continue
    fi

    printf -v CERT -- '-----BEGIN CERTIFICATE-----\n%s\n-----END CERTIFICATE-----\n' "$RAW_CERT"

    verify_key_size "$CERT" "$md_file"
    verify_expire_date "$CERT"  "$md_file"
done
