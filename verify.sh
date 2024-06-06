#!/bin/sh

#https://stacklok.com/blog/validate-and-track-signatures-of-oci-images-using-cosign-and-rekor
SIG=$(cosign  triangulate ghcr.io/cplee/gh-attest-demo:main)

crane manifest $SIG | jq -r '.layers[0].annotations["dev.sigstore.cosign/certificate"]' > /tmp/signature.crt
openssl x509 -in /tmp/signature.crt -text -noout

IDENTITY=$(openssl x509 -in /tmp/signature.crt -noout -ext subjectAltName  | awk -F 'URI:' '{print $2}' | tr -d '\n')
ISSUER=$(openssl x509 -in /tmp/signature.crt -text -noout | awk '/1.3.6.1.4.1.57264.1.1:/  {getline;  sub(/^[ \t]+/, "");print}')

cosign verify --certificate-oidc-issuer $ISSUER --certificate-identity $IDENTITY ghcr.io/cplee/gh-attest-demo:main