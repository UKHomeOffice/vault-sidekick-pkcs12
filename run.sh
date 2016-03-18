#!/bin/bash

set -e


if [ "${VAULT_TOKEN}" != "" ]; then
    echo "VAULT_TOKEN set using vault for certs against $VAULT_HOST for the DOMAIN ${SERVICE}.${DOMAIN}"
    DATA="{\"common_name\": \"${SERVICE}.${DOMAIN}\" }"
    PATHDOMAIN=`echo ${DOMAIN} | sed -e 's/\./-/g'`

    TEMPFILE=`mktemp`
    KEYSTORE=/tmp/keystore.p12
    TRUSTSTORE=/tmp/truststore.p12
    KEYPASS=`openssl rand -base64 18`

    # This file comes from a Volume that we mount in the Pod
    # /etc/sslca/platform-ca.pem

    curl -L -vvv --cacert /etc/sslca/platform-ca.pem -X PUT  -H 'Content-type: application/json'  -H "X-Vault-Token:${VAULT_TOKEN}" \
       -o ${TEMPFILE} \
       -d "${DATA}" ${VAULT_HOST}v1/pki/issue/${PATHDOMAIN}

    # get the data we want from it all
    cat ${TEMPFILE} | jq .data.certificate | sed -e 's/"//g' -e 's/\\n/\x0a/g' > /tmp/crt.pem
    cat ${TEMPFILE} | jq .data.private_key | sed -e 's/"//g' -e 's/\\n/\x0a/g' > /tmp/key.pem
    cat ${TEMPFILE} | jq .data.issuing_ca | sed -e 's/"//g' -e 's/\\n/\x0a/g' > /tmp/ca.pem
    RENEW_TIME=`cat ${TEMPFILE} | jq .lease_duration | sed -e 's/"//g' -e 's/\\n/\x0a/g'`
    # Remove a random 10% from the time NOTE if < 100 this does not work will just be 100%
    RENEW_TIME=$(($RENEW_TIME - ($RENEW_TIME / 100 * ($RANDOM % 10 ))))
    rm ${TEMPFILE}

    cat /dev/null > ${KEYSTORE}
    # now convert to pkcs
    openssl pkcs12 -export -in /tmp/crt.pem -inkey /tmp/key.pem -out ${KEYSTORE} -passout pass:${KEYPASS} -name "newname"
    # add our authority to the keystore
    #keytool -import -noprompt -trustcacerts -alias ourcert -file /tmp/ca.pem -keystore ${KEYSTORE} -storepass ${KEYPASS}
    echo "adding our ca to the main java truststore"
    keytool -import -noprompt -trustcacerts -file /tmp/ca.pem -alias ourcert -keystore /etc/ssl/certs/java/cacerts -storepass changeit
else
	echo "Vault token not found"
            exit 1
fi
