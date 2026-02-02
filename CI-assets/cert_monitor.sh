#!/bin/bash

# Emails will be sent on these days left to certificate expiration date
DAYS2WARN=(7 15 22 30)
MAX_WARN=$(printf "%s\n" "${DAYS2WARN[@]}" | sort -nr | head -1)


parse_date() {
    if date --version >/dev/null 2>&1; then
        date -d "$1" +%s
    else
        date -j -f "%b %d %H:%M:%S %Y %Z" "$1" +%s
    fi
}

get_days_to_expire() {
    local CERT="$1"
    local FILE="$2"

    local ENDDATE=$(printf "%s" "$CERT" \
        | openssl x509 -enddate -noout -in /dev/stdin \
        | cut -d= -f2)

    if [[ -z "$ENDDATE" ]]; then
        echo "Could not parse certificate in $FILE"
        return 1
    fi

    local EXPIRY_EPOCH=$(parse_date "$ENDDATE")

    if [[ -z "$EXPIRY_EPOCH" ]]; then
        echo "Could not parse expiry date in $FILE"
        return 1
    fi

    local NOW_EPOCH=$(date +%s)

    # Calculate days left (rounded down)
    local DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))

    # clamp negative values to zero
    (( DAYS_LEFT < 0 )) && DAYS_LEFT=0

    echo "$DAYS_LEFT"
}

send_email_warning() {
    local DAYS_LEFT=$1
    local CERT=$2
    local CC_ADDR="spf@clarin.eu"
    local md_file=$3
    local prefix=""

    [[ "$DAYS_LEFT" -lt "$MAX_WARN" ]] && prefix="(Reminder!) "

    local owner_email=$(xmllint --xpath \
      '/*[local-name()="EntityDescriptor"]/*[local-name()="ContactPerson" and @contactType="technical"]/*[local-name()="EmailAddress"][1]/text()' "$md_file"\
      | sed 's/^mailto://')

    local subject="${prefix}Your CLARIN Service Provider certificate is expiring in $DAYS_LEFT days"
    local body="Dear service provider operator,

The certificate of your Service Provider in the CLARIN SPF will expire in $DAYS_LEFT days.
Update your SP metadata file at:
https://github.com/clarin-eric/SPF-SPs-metadata/tree/master/$md_file
according to the instructions provided in the base of the repository README.md
https://github.com/clarin-eric/SPF-SPs-metadata/blob/master/README.md

If you already updated the certificate and this message is about the old certificate which you left in place for certificate rollover,
now is the time to remove the old certificate.

For intructions about how to create and rollover your new certificate without service disruption see:
https://doku.tid.dfn.de/en:certificates#information_for_service_providers and
https://help.switch.ch/aai/guides/sp/certificate-rollover/

If you can accept some service disruption, then you can just replace the certificate with a new one.

$(printf "%s" "$CERT" \
        | openssl x509 -noout -text -in /dev/stdin \
        | sed '/^[[:space:]]*[0-9a-f]\{2\}:/d')

If you have any further questions you can always contact us via spf@clarin.eu

Regards,
CLARIN SPF team
- This message is automatically generated. Please do not reply directly to it -
"

    printf "To: %s\nCc: %s\nSubject: %s\n\n%s" \
        "$owner_email" "$CC_ADDR" "$subject" "$body" \
        | msmtp "$owner_email"


    echo "Sent email to $owner_email for $(basename "$md_file")"

}

check_file() {
    local md_file="$1"
    echo "Checking file $md_file:"

    xmllint --noout "$md_file" || { echo "Invalid XML"; return 1; }

    # Count certificates
    count=$(xmllint --xpath "count(//*[local-name()='X509Certificate'])" "$md_file" 2>/dev/null)
    count=${count%.*}

    if [ -z "$count" ] || [ "$count" -eq 0 ]; then
        echo "No certificate found in $md_file"
        return 1
    fi

    i=1

    while [ "$i" -le "$count" ]; do
        RAW_CERT=$(xmllint --xpath "(//*[local-name()='X509Certificate'])[$i]/text()" "$md_file" 2>/dev/null \
            | tr -d ' \t\n\r')

        CERT="-----BEGIN CERTIFICATE-----
$RAW_CERT
-----END CERTIFICATE-----"

        DAYS_LEFT=$(get_days_to_expire "$CERT" "$md_file")

        if [[ " ${DAYS2WARN[@]} " =~ " $DAYS_LEFT " ]]; then
            echo "Certificate in ${md_file} is expiring in ${DAYS_LEFT} days. Sending warning email to maintainers"
            send_email_warning "$DAYS_LEFT" "$CERT" "$md_file"
        else
            echo "Certificate expiration does not match any defined warning notification day."
        fi

        i=$((i + 1))
    done

    return 0
}

check_all_files_in_dir() {
    shopt -s nullglob
    local rc=0
    for md_file in "$1"/*; do
        if ! check_file "$md_file"; then
            rc=1
        fi
    done
    shopt -u nullglob

    return $rc
}

#
# Execute
#
check_all_files_in_dir metadata

exit 0
