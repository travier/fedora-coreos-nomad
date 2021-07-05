client {
  enabled = true
  servers = [ "%%BOOTSTRAP_IP%%:4647" ]
}

tls {
  http = true
  rpc  = true

  ca_file   = "/etc/nomad.certs/nomad-ca.pem"
  cert_file = "/etc/nomad.certs/client.pem"
  key_file  = "/etc/nomad.certs/client-key.pem"

  verify_server_hostname = true
  verify_https_client    = true
}
