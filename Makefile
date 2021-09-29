.PHONY: all common bootstrap servers clients
OUTPUT ?= ignition

include secrets


${OUTPUT}:
	mkdir -p ${OUTPUT}

all: ${OUTPUT}
	make bootstrap
	make servers
	make clients

common: ${OUTPUT}
	rm -rf ./config
	cp -a template config
	cp -a tls config/tls
	find config/ -type f -print0 | xargs -0 sed -i 's/%%DATACENTER%%/${DATACENTER}/g'

bootstrap: common
	find config/ -type f -print0 | xargs -0 sed -i 's/%%CONSUL_ENCRYPT_KEY%%/${CONSUL_ENCRYPT_KEY}/g'
	sed 's|%%SSH_PUBKEY%%|${SSH_PUBKEY}|' common.bu | cat - bootstrap.bu | sed 's|%%NODE_IP_SUFFIX%%|100|' | sed 's|%%NODE_DNS%%|${NODE_DNS}|' | sed 's|%%NODE_GATEWAY%%|${NODE_GATEWAY}|' | sed 's|%%NODE_IP_PREFIX%%|${NODE_IP_PREFIX}|' | butane --files-dir config --strict --output ${OUTPUT}/server-0.ign

servers: common
	find config/ -type f -print0 | xargs -0 sed -i 's/%%BOOTSTRAP_IP%%/${BOOTSTRAP_IP}/g'
	find config/ -type f -print0 | xargs -0 sed -i 's/%%CONSUL_ENCRYPT_KEY%%/${CONSUL_ENCRYPT_KEY}/g'
	sed 's|%%SSH_PUBKEY%%|${SSH_PUBKEY}|' common.bu | cat - server.bu | sed 's|%%NODE_IP_SUFFIX%%|101|' | sed 's|%%NUMBER%%|1|' | sed 's|%%NODE_DNS%%|${NODE_DNS}|' | sed 's|%%NODE_GATEWAY%%|${NODE_GATEWAY}|' | sed 's|%%NODE_IP_PREFIX%%|${NODE_IP_PREFIX}|' | butane --files-dir config --strict --output ${OUTPUT}/server-1.ign
	sed 's|%%SSH_PUBKEY%%|${SSH_PUBKEY}|' common.bu | cat - server.bu | sed 's|%%NODE_IP_SUFFIX%%|102|' | sed 's|%%NUMBER%%|2|' | sed 's|%%NODE_DNS%%|${NODE_DNS}|' | sed 's|%%NODE_GATEWAY%%|${NODE_GATEWAY}|' | sed 's|%%NODE_IP_PREFIX%%|${NODE_IP_PREFIX}|' | butane --files-dir config --strict --output ${OUTPUT}/server-2.ign

clients: common
	find config/ -type f -print0 | xargs -0 sed -i 's/%%BOOTSTRAP_IP%%/${BOOTSTRAP_IP}/g'
	find config/ -type f -print0 | xargs -0 sed -i 's/%%CONSUL_ENCRYPT_KEY%%/${CONSUL_ENCRYPT_KEY}/g'
	sed 's|%%SSH_PUBKEY%%|${SSH_PUBKEY}|' common.bu | cat - client.bu | sed 's|%%NODE_IP_SUFFIX%%|110|' | sed 's|%%NUMBER%%|0|' | sed 's|%%NODE_DNS%%|${NODE_DNS}|' | sed 's|%%NODE_GATEWAY%%|${NODE_GATEWAY}|' | sed 's|%%NODE_IP_PREFIX%%|${NODE_IP_PREFIX}|' | butane --files-dir config --strict --output ${OUTPUT}/client-0.ign
	sed 's|%%SSH_PUBKEY%%|${SSH_PUBKEY}|' common.bu | cat - client.bu | sed 's|%%NODE_IP_SUFFIX%%|111|' | sed 's|%%NUMBER%%|1|' | sed 's|%%NODE_DNS%%|${NODE_DNS}|' | sed 's|%%NODE_GATEWAY%%|${NODE_GATEWAY}|' | sed 's|%%NODE_IP_PREFIX%%|${NODE_IP_PREFIX}|' | butane --files-dir config --strict --output ${OUTPUT}/client-1.ign
	sed 's|%%SSH_PUBKEY%%|${SSH_PUBKEY}|' common.bu | cat - client.bu | sed 's|%%NODE_IP_SUFFIX%%|112|' | sed 's|%%NUMBER%%|2|' | sed 's|%%NODE_DNS%%|${NODE_DNS}|' | sed 's|%%NODE_GATEWAY%%|${NODE_GATEWAY}|' | sed 's|%%NODE_IP_PREFIX%%|${NODE_IP_PREFIX}|' | butane --files-dir config --strict --output ${OUTPUT}/client-2.ign
