job "example" {
  # CHANGE ME FOR YOUR DC NAME!
  datacenters = ["fcos-nomad-demo"]

  group "cache" {
    count = 3

    network {
      port "db" {
        to = 6379
      }
    }

    task "redis" {
      driver = "podman"

      config {
        image = "docker.io/redis:3.2"

        ports = ["db"]
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
