datacenter = "%%DATACENTER%%"
data_dir = "/var/lib/consul"
enable_syslog = true
log_level = "info"
encrypt = "%%CONSUL_ENCRYPT_KEY%%"
verify_incoming = true
verify_outgoing = true
verify_server_hostname = false
ports {  http = -1  https = 8501}
