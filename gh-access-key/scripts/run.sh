#!/bin/bash
set -e



getToken(){
    APP_ID='946286'
    INSTALLATION_ID='52855754'
    PRIVATE_KEY_PATH="cicd-bot-pk.pem"
    echo $INPUT_NB_CICD_BOT_PK>$PRIVATE_KEY_PATH
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
    botTokenResponse=$(curl -X POST \
        -H "Authorization: Bearer $JWT" \
        -H "Accept: application/vnd.github+json" \
        https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens 2>/dev/null)
    #echo botTokenResponse: $botTokenResponse
    botToken=$(echo $botTokenResponse| jq -r .token)
    echo "GH_ACCESS_KEY=$botToken" >> $GITHUB_ENV
}

echo INPUT_NB_CICD_BOT_PK: $INPUT_NB_CICD_BOT_PK
getToken
echo getToken finshed ok.
