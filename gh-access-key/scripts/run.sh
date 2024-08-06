#!/bin/bash
set -e

ensure_dependencies(){
    if command -v curl >/dev/null 2>&1; then
        echo curl is installed
        return 0
    fi
    if command -v apk >/dev/null 2>&1; then
        if [[ "$(whoami)" == "root" ]]; then
            apk update && apk add curl
        else
            sudo apk update && sudo apk add curl
        fi
    elif command -v apt-get >/dev/null 2>&1; then
        if [[ "$(whoami)" == "root" ]]; then
            apt-get update && apt-get install -y curl
        else
            sudo apt-get update && sudo apt-get install -y curl
        fi
    fi
}

getToken(){
    set -e
    APP_ID='946286'
    INSTALLATION_ID='52855754'
    PRIVATE_KEY_PATH="nb-cicd-bot-pk.pem"
    # Get the current time and the expiration time (10 minutes from now)
    NOW=$(date +%s)
    EXPIRATION=$(($NOW + 600))

    # Create the JWT header
    HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')

    # Create the JWT payload
    PAYLOAD=$(echo -n "{\"iat\":$NOW,\"exp\":$EXPIRATION,\"iss\":$APP_ID}" | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')

    # Sign the JWT
    SIGNATURE=$(echo -n "$HEADER.$PAYLOAD" | openssl dgst -sha256 -sign $PRIVATE_KEY_PATH | openssl base64 -e | tr -d '=' | tr '/+' '_-' | tr -d '\n')
    rm $PRIVATE_KEY_PATH

    # Combine the JWT components
    JWT="$HEADER.$PAYLOAD.$SIGNATURE"

    # Request the installation access token
    botToken=$(curl -X POST \
        -H "Authorization: Bearer $JWT" \
        -H "Accept: application/vnd.github+json" \
        https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens 2>/dev/null | grep '"token":' | awk -F'"' '{print $4}')
    #echo botTokenResponse: $botTokenResponse
    echo "GH_ACCESS_KEY=$botToken" >> $GITHUB_ENV
}

ensure_dependencies
getToken
echo getToken finshed ok.
