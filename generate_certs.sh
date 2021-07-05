#!/bin/env bash

set -eu -o pipefail
# set -x

main() {
	rm -rf ./tls
	mkdir tls
	pushd tls

	# Generate the CA's private key and certificate
	cfssl print-defaults csr | cfssl gencert -initca - | cfssljson -bare nomad-ca

	# Generate a certificate for the Nomad server
	echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -config=../cfssl.json \
		-hostname="server.global.nomad,localhost,127.0.0.1" - | cfssljson -bare server

	# Generate a certificate for the Nomad client
	echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -config=../cfssl.json \
		-hostname="client.global.nomad,localhost,127.0.0.1" - | cfssljson -bare client

	# Generate a certificate for the CLI
	echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -profile=../client \
		- | cfssljson -bare cli

	openssl pkcs12 -export -out tls/cli.p12 -in tls/cli.pem -inkey tls/cli-key.pem

	popd
}

main "${@}"
