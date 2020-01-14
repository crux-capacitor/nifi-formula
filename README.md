# NiFi Formula

This formula can be used to install NiFi and apply a handful of different configurations, such as:

 * clustering using embedded ZK
    * it even supports multiple named clusters so you can run different flows
 * secured cluster communications
 * running the UI on HTTPS
 * standalone TLS mode
 * usage of a 2nd disk for storage of the flowfile, provenance, etc

## Prerequisites

This formula requires a few things to run smoothly.

1. Custom grain `role` set to `nifi` on all NiFi servers.

    See the `ec2-userdata.example` file  for an example of doing this.

1. Custom grain `private_ip` set to the system's private IP address on the network (not a list of IPs).

    <details>
    <summary>Complete code for this custom grain</summary>

    ```python
    #!/usr/bin/env python
    import socket

    def main():
      grains = {}
      grains['private_ip'] = socket.gethostbyname(socket.gethostname())
      return grains
      ```
    </details>

1. Custom grain `ec2`.

    You can get the custom grain script [here](https://raw.githubusercontent.com/saltstack/salt-contrib/master/grains/ec2_info.py).
1. Put the `cluster_pillar.example` file in pillar roots (renamed to `cluster.sls`), and apply to all NiFi servers.
1. The following mine function on all NiFi servers. Set via minion config or pillar.

    ```
    mine_functions:
      private_ip:
        mine_function: network.ip_addrs
        cidr: <CIDR range of your network>
    ```

1. Syncing pillar and custom grains before highstating when the minions start. See [here](https://docs.saltstack.com/en/latest/topics/reactor/#syncing-custom-types-on-minion-start)

### For Secure Clustering
1. Put the `certificates_pillar.example` file in pillar roots (renamed to `certificates.sls`), and apply to all NiFi servers.
1. Fill out the `certificates.sls` pillar file with the CA certificate material, following the example format. If your organization has a CA, use that to generate a signed certificate to be used here. If not, a self-signed CA cert to be used to generate the NiFI node certificates is common practice. See instructions below.

   Instructions on generating a cert using the NiFi TLS toolkit are [here](https://nifi.apache.org/docs/nifi-docs/html/toolkit-guide.html#standalone)

   Here is an example command to create a self-signed CA cert to be used when generating the cluster node certificates:

   `./tls-toolkit.sh standalone -n nifi-ca -o .`

   This will generate a new folder in the current folder named `nifi-ca`.

   In there you'll find `nifi-cert.pem` and `nifi-key.key`. These are what you need to put into the `certificates.sls` pillar file, into `ca_cert` and `ca_key`, respectively.

## Configuration

Configuration of the formula is done through the `config.yaml` file.

Each of the state files that take part in either the installation, configuration, or maintenance of NiFi have a section in that file, and each section has some options that can be tuned.

## Clustering

Clustering your NiFi servers can be set up manually in the `config.yaml` file, or you can use AWS EC2 instance user data to do it.

See the `ec2-userdata.example` file for a complete example of a bootstrap script that installs Salt, and sets up dynamic clustering.

The following lines can be added to user data to facilitate this:
```
cluster=<arbitrary name>
type=<embedded or external (embedded is default)>
```

For example:
```
cluster=central-logging
type=embedded
```

Those two values are parsed out and stored in pillar:
1. nifi:cluster:name
1. nifi:cluster:type

Existence of the pillar value `nifi:cluster` is what causes the server to be clustered with other NiFi servers that have the same cluster name. In the example above, all NiFi servers where the pillar value `nifi:cluster:name` equals `central-logging` will be clustered together to run the same flow.

The `cluster.yaml` file has code that runs when this pillar value is found. It uses the Salt Mine to find all the other NiFi servers that have the same cluster name, and builds a list of them that is fed into the `nifi.properties` file and `zookeeper.properties` files to connect the servers together.

When the `type` is `embedded`, the embedded zookeeper server is enabled and is fed the connect string that is determined by the logic in the `cluster.yaml` file.

Additionally, each new NiFi node will run an embedded zookeeper server, and so the zookeeper cluster will grow with each new NiFi node.

## Secure Cluster Setup

This formula can automate a secure NiFi cluster that:

1. Runs the NiFi UI over HTTPS
1. Secures NiFi cluster communication using certificates
1. Has a certificate-based initial admin identity

To do this, the `certificates_pillar.example` pillar needs to be filled out with the shared CA certificate material that is used to generate the NiFi node certificates.

By using a shared CA certificate during this process, the NiFi nodes will automatically trust eachother, greatly simplifying the secure-clustering setup.

You can enable this configuration in the `config.yaml` file by setting it like this:

```yaml
config:
  web:
    protocol: https            # http or https
    port: 8443

  tls:
    enabled: True
```