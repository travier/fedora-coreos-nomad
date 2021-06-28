# Butane configs to deploy Nomad on Fedora CoreOS

The Butane configurations from this project will deploy Nomad as described in
the [Nomad Reference Architecture][nomad-ref-arch], using the [podman
driver][podman-driver].

This also includes support for the [Enable TLS Encryption for Nomad][nomad-tls]
guide.

This will enable you to setup:
  * A Nomad bootstrap server,
  * Two other servers to enable the election to proceed and have a leader and
    two followers,
  * Three clients (but you can spawn as many as you need for your workload).

Note that this setup does not currently include Consul and Vault which are
recommended in production setups.

## How to use

To generate the Ignition configs, you need `make` and [Butane][butane].

First, we have to specify a few values that are deployment specific and that
will be included in configuration files. Use the example `secrets.example` file
as template and copy it to `secrets`:

```
$ cp secrets.example secrets
```

You can now set your SSH public key (`SSH_PUBKEY`) and choose a name for your
datacenter (`DATACENTER`). You can ignore the remaining values for now:

```
$ ${EDITOR} secrets
```

### Deploying the bootstrap server

We will then generate the bootstrap config and deploy an instance to be able to
retreive its internal address that we will use for the other servers and
clients:

```
$ make bootstrap
```

This will generate the `server-1.ign` Ignition config that you can use to
deploy your Fedora CoreOS Nomad bootstrap server. See the [Fedora CoreOS
docs][deploy] for instructions on how to use this Ignition config to deploy a
Fedora CoreOS instance on your prefered platform.

### Deploying the followers and the clients

You can now set the bootstrap server IP variable in the secrets file:

```
$ ${EDITOR} secrets
```

And then generate the configurations for the additionnal servers:

```
$ make servers
```

This will generate the `server-{2,3}` Ignition configs that you can use to
deploy the two additional server instances.

Then do the same for the clients:

```
$ make clients
```

This will generate the `client-{1,2,3}` Ignition configs that you can use to
deploy the three client instances.

### Testing using a podman example job

You can test your Nomad deployment with the following Redis example job,
adapted from the default example for podman. Note that container image names
have to be fully qualified:

```
$ cat example.nomad
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
```

Note that Fedora CoreOS can only use one container runtime at a time thus you
have to decide which one of podman or docker you would prefer to use at the
beginning.

## System and container updates

By default, Fedora CoreOS systems are updated automatically to the latest
released update. This makes sure that the system is always on top of security
issues (and updated with the latest features) wthout any user interaction
needed. The containers, as defined in the systemd units in the config, are
updated on each service startup. They will thus be updated at least once after
each system update as this will trigger a reboot approximately every two week.

To maximise availability, you can set an [update strategy][updates] in
Zincati's configuration to only allow reboots for updates during certain
periods of time.  For example, one might want to only allow reboots on week
days, between 2 AM and 4 AM UTC, which is a timeframe where reboots should have
the least user impact on the service. Make sure to pick the correct time for
your timezone as Fedora CoreOS uses the UTC timezone by default.

See this example config that you can append to `common.bu`:

```
[updates]
strategy = "periodic"

[[updates.periodic.window]]
days = [ "Mon", "Tue", "Wed", "Thu", "Fri" ]
start_time = "02:00"
length_minutes = 120
```

You might also want to use a fleet coordinator to orchestrate node reboots.
This project should help you get started: <https://github.com/coreos/airlock>.

[nomad-ref-arch]: https://learn.hashicorp.com/tutorials/nomad/production-reference-architecture-vm-with-consul
[podman-driver]: https://github.com/hashicorp/nomad-driver-podman
[nomad-tls]: https://learn.hashicorp.com/tutorials/nomad/security-enable-tls
[butane]: https://coreos.github.io/butane/getting-started/#getting-butane
[deploy]: https://docs.fedoraproject.org/en-US/fedora-coreos/getting-started/
[updates]: https://coreos.github.io/zincati/usage/updates-strategy/#periodic-strategy
