#!/bin/bash

LOG_LEVEL="info"

CLOUDFLARE_DNS_COMMENTS="homeserver"

NTFY_ENABLED=1
NTFY_TITLE="Updated CF DNS A record ip addresses"
NTFY_TAGS="computer,cd,+1,update-cf-ip"
DEBUG=0


ip=$(curl -s -4 https://cloudflare.com/cdn-cgi/trace | awk -F'ip=' 'NF>1{print $2}')

if [ -s ".env" ]; then
    set -a
    # shellcheck source=/dev/null
    source ".env"
    set +a
fi

init () {
    if [ -x "$(command -v lj)" ]; then
        if [ "$DEBUG" -lt 1 ]; then
            lj --file logs/update_cf_ip.log $LOG_LEVEL
        else
            lj --file /dev/stdout DEBUG
        fi
    fi
}

log() {
	# [NOTICE] [2024-03-13 23:02:09]
	log_level=${2:-"INFO"}
	echo_message="[$log_level] [$(date '+%Y-%m-%d %H:%M:%S')]: $1"
	if [ -x "$(command -v lj)" ]; then
		if [ $# -eq 2 ]; then
			lj "$2" "$1"
		else
			lj "$1"
		fi
	else
		echo "$echo_message	"
	fi
}

send_notification () {
    message=$1
    lj "$message"
    if [ "$NTFY_ENABLED" -eq 0 ]; then
        log "Tried to run send_notification, but it is not enabled."
        log "Tried to send: $message"  
        return
    fi
    headers=(
        -H
        "Title: $NTFY_TITLE"
        -H
        "Tags: $NTFY_TAGS"
    )


    if [ "$NTFY_AUTH_HEADER" ]; then
        headers+=(-H "$NTFY_AUTH_HEADER")
    fi

	curl -X POST "$NTFY_URL" -s -o /dev/null \
        "${headers[@]}" \
	    --data-binary @- <<EOF
$message
EOF
}

init

mapfile -t DNS_A_RECORDS <  <(curl -s -H "$CLOUDFLARE_AUTH_HEADER" \
    "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records?type=A&comment=$CLOUDFLARE_DNS_COMMENTS" \
    | jq -r '.result[] | "\(.id)|\(.content)|\(.name)"')

updated_any=false
for each in "${DNS_A_RECORDS[@]}"
do
    IFS='|' read -r dns_id content name <<<"$each"
    if [ "$content" != "$ip" ]; then
    curl --request PATCH -s \
        --url "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$dns_id" \
        --header "$CLOUDFLARE_AUTH_HEADER" \
        --header 'Content-Type: application/json' \
        --data "{
            \"content\": \"$ip\"
        }"

        message="$name was outdated ($content). Updated to $ip"
        send_notification "$message"
        updated_any=true
    fi
done
if [ "$updated_any" = false ]; then
    send_notification "No records to update. All are up to date. :-)"
fi
