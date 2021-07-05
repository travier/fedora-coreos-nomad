.PHONY: all common bootstrap servers clients

include secrets

all:
	make bootstrap
	make servers
	make clients

common:
	rm -rf ./config
	cp -a template config
	cp -a tls config/tls
	find config/ -type f -print0 | xargs -0 sed -i 's/%%DATACENTER%%/${DATACENTER}/g'

bootstrap: common
	sed 's|%%SSH_PUBKEY%%|${SSH_PUBKEY}|' common.bu | cat - bootstrap.bu | butane --files-dir config --strict --output server-1.ign

servers: common
	find config/ -type f -print0 | xargs -0 sed -i 's/%%BOOTSTRAP_IP%%/${BOOTSTRAP_IP}/g'
	sed 's|%%SSH_PUBKEY%%|${SSH_PUBKEY}|' common.bu | cat - server.bu | sed 's|%%NUMBER%%|2|' | butane --files-dir config --strict --output server-2.ign
	sed 's|%%SSH_PUBKEY%%|${SSH_PUBKEY}|' common.bu | cat - server.bu | sed 's|%%NUMBER%%|3|' | butane --files-dir config --strict --output server-3.ign

clients: common
	find config/ -type f -print0 | xargs -0 sed -i 's/%%BOOTSTRAP_IP%%/${BOOTSTRAP_IP}/g'
	sed 's|%%SSH_PUBKEY%%|${SSH_PUBKEY}|' common.bu | cat - client.bu | sed 's|%%NUMBER%%|1|' |  butane --files-dir config --strict --output client-1.ign
	sed 's|%%SSH_PUBKEY%%|${SSH_PUBKEY}|' common.bu | cat - client.bu | sed 's|%%NUMBER%%|2|' |  butane --files-dir config --strict --output client-2.ign
	sed 's|%%SSH_PUBKEY%%|${SSH_PUBKEY}|' common.bu | cat - client.bu | sed 's|%%NUMBER%%|3|' |  butane --files-dir config --strict --output client-3.ign
