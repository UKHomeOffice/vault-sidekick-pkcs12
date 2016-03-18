# Vault sidekick pkcs12

Sidekick container to run it in Kubernetes as part of a `Pod`. It receives some parameters that will allow to connect to a Vault instance, pull a certificate,
format it as `pkcs12` and add it to a java keystore.


## Parameters

* VAULT_TOKEN = token the can be used to access vault
* VAULT_HOST = the ELB / host of vault

* SERVICE =  the name of the service so the cert will be for SERVICE.DOMAIN
* DOMAIN = the subdomain this is to be under (if blank try and find it)

to run it:

docker run -it  \
     -e VAULT_TOKEN=$VAULT_TOKEN \
     -e VAULT_HOST=$VAULT_HOST \
     -e SERVICE=$SERVICE \
     -e DOMAIN=$DOMAIN \
            quay.io/ukhomeofficedigital/vault-sidekick-pkcs


Keystore location is located at `/etc/ssl/certs/java/cacerts`
