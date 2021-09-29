server = true
ui_config{
  enabled = true
}
client_addr = "0.0.0.0"
advertise_addr = ""
advertise_addr_wan = ""
bind_addr = "{{GetInterfaceIP \"ens18\"}}"
bootstrap_expect = 3
ca_file   = "/etc/nomad.certs/nomad-ca.pem"
cert_file = "/etc/nomad.certs/server.pem"
key_file  = "/etc/nomad.certs/server-key.pem"
telemetry {
  disable_compat_1.9 = true
}
