#!/bin/bash

DAYS=30
REQUIRED_BITS=3072

CHECK_FILE=0
CHECK_DIR=0
HELP=0
FILENAME=""
DIRNAME=""

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Checks SAML metadata files for:
  • X.509 certificate key size (minimum: ${REQUIRED_BITS} bits)
  • Certificate expiration (warning if expiring within ${DAYS} days)

Options:
  -f <file>     Check a single metadata file.
  -d <dir>      Check all metadata files in a directory.
  -h            Show this help message.

Examples:
  $(basename "$0") -f metadata.xml
  $(basename "$0") -d /path/to/metadata/

Notes:
  • Extracts the <X509Certificate> element from the metadata.
  • Validates certificate key size and expiration date.
  • Compatible with GNU/Linux and macOS.

EOF
}

#
# Parse arguments
#
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -f)
            CHECK_FILE=1
            FILENAME="$2"
            shift
            ;;
        -d)
            CHECK_DIR=1
            DIRNAME="$2"
            shift
            ;;
        -h|--help)
            HELP=1
            ;;
        *)
            echo "Unknown option: ${key}"
            HELP=1
            ;;
    esac
    shift
done

#
# Validate arguments
#
if [[ $HELP -eq 1 ]]; then
    show_help
    exit 0
fi

if [[ $CHECK_FILE -eq 1 && -z "$FILENAME" ]]; then
    echo "Error: -f requires a filename."
    show_help
    exit 1
fi

if [[ $CHECK_DIR -eq 1 && -z "$DIRNAME" ]]; then
    echo "Error: -d requires a directory."
    show_help
    exit 1
fi

if [[ $CHECK_FILE -eq 1 && ! -f "$FILENAME" ]]; then
    echo "Error: File not found: $FILENAME"
    exit 1
fi

if [[ $CHECK_DIR -eq 1 && ! -d "$DIRNAME" ]]; then
    echo "Error: Directory not found: $DIRNAME"
    exit 1
fi

#
# Utility functions
#
parse_date() {
    if date --version >/dev/null 2>&1; then
        date -d "$1" +%s
    else
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

    if [[ -z "$KEY_BITS" ]]; then
        echo "Could not determine key size in $FILE"
        return 1
    fi

    if (( KEY_BITS < REQUIRED_BITS )); then
        echo -e "\t❌ Key size too small: ${KEY_BITS} bits (minimum is ${REQUIRED_BITS})"
        return 1
    else
        echo -e "\t🔐 Key size OK: ${KEY_BITS} bits"
    fi
}

verify_expire_date() {
    CERT="$1"
    FILE="$2"

    ENDDATE=$(printf "%s" "$CERT" \
        | openssl x509 -enddate -noout -in /dev/stdin \
        | cut -d= -f2)

    if [[ -z "$ENDDATE" ]]; then
        echo "Could not parse certificate in $FILE"
        return 1
    fi

    EXPIRY_EPOCH=$(parse_date "$ENDDATE")

    if [[ -z "$EXPIRY_EPOCH" ]]; then
        echo "Could not parse expiry date in $FILE"
        return 1
    fi

    NOW_EPOCH=$(date +%s)
    THIRTY_DAYS=$(( DAYS * 24 * 3600 ))
    WARNING_EPOCH=$(( NOW_EPOCH + THIRTY_DAYS ))

    # Calculate days left (rounded down)
    DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))

    if (( EXPIRY_EPOCH < NOW_EPOCH )); then
        echo -e "\t❌ Certificate has already expired. Expired ${DAYS_LEFT#-} days ago."
        return 1

    elif (( EXPIRY_EPOCH < WARNING_EPOCH )); then
        echo -e "\t⚠️ Certificate will expire within ${DAYS} days. Currently ${DAYS_LEFT} days left."

    else
        echo -e "\t✅ Certificate is valid for more than ${DAYS} days. Currently ${DAYS_LEFT} days left."
    fi
}

check_file() {
    md_file="$1"
    echo "Checking file $md_file:"

    # Count certificates
    count=$(xmllint --xpath "count(//*[local-name()='X509Certificate'])" "$md_file" 2>/dev/null)
    count=${count%.*}

    if [ -z "$count" ] || [ "$count" -eq 0 ]; then
        echo "No certificate found in $md_file"
        return 1
    fi

    any_passed=0
    i=1

    while [ "$i" -le "$count" ]; do
        RAW_CERT=$(xmllint --xpath "(//*[local-name()='X509Certificate'])[$i]/text()" "$md_file" 2>/dev/null \
            | tr -d ' \t\n\r')

        CERT="-----BEGIN CERTIFICATE-----
$RAW_CERT
-----END CERTIFICATE-----"

        verify_key_size "$CERT" "$md_file"
        rc1=$?

        verify_expire_date "$CERT" "$md_file"
        rc2=$?

        # Certificate passes only if BOTH checks succeed
        if [ $rc1 -eq 0 ] && [ $rc2 -eq 0 ]; then
            any_passed=1
        fi

        i=$((i + 1))
    done

    # If no certificate passed → return 1
    if [ $any_passed -eq 0 ]; then
        return 1
    fi

    return 0
}

check_all_files_in_dir() {
    shopt -s nullglob
    rc=0
    for md_file in "$1"/*; do
        if ! check_file "$md_file"; then
            rc=1
        fi
    done
    shopt -u nullglob
}

#
# Execute
#
ec=0
if [[ $CHECK_FILE -eq 1 ]]; then
    if ! check_file "$FILENAME"; then
        ec=1
    fi
elif [[ $CHECK_DIR -eq 1 ]]; then
    if ! check_all_files_in_dir "$DIRNAME"; then
        ec=1
    fi
else
    show_help
fi

exit "${ec}"

