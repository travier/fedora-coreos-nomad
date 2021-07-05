server {
  enabled = true
  bootstrap_expect = 3

  server_join {
    retry_join = ["%%BOOTSTRAP_IP%%:4648"]
  }
}

tls {
  http = true
  rpc  = true

  ca_file   = "/etc/nomad.certs/nomad-ca.pem"
  cert_file = "/etc/nomad.certs/server.pem"
  key_file  = "/etc/nomad.certs/server-key.pem"

  verify_server_hostname = true
  verify_https_client    = true
}
