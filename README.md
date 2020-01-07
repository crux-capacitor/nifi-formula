# NiFi Formula

This formula can be used to install NiFi and apply a handful of different configurations, such as:

 * clustering using embedded ZK
    * it even supports multiple named clusters so you can run different flows
 * secured cluster communications
 * running the UI on HTTPS
 * standalone TLS mode
 * usage of a 2nd disk for storage of the flowfile, provenance, etc

This was designed to run on AWS and is optimized to be installed on Amazon Linux 2 instances, however it should work on RedHat and Ubuntu as well.

## Prerequisites

This formula requires a few things to run smoothly.

1. Custom grain `role` set to `nifi` on all NiFi servers.
1. Custom grain `private_ip` set to the system's private IP address on the network (not a list of IPs).
   
   You can get the custom grain script [here](https://raw.githubusercontent.com/crux-capacitor/salt-master/master/salt/_grains/private_ip.py?token=AEJ3RR523D5NYW5Y5Z3YMJS6CT26U).
1. Custom grain `ec2`.

   You can get the custom grain script [here](https://raw.githubusercontent.com/saltstack/salt-contrib/master/grains/ec2_info.py).
1. Put the `cluster_pillar.example` file in pillar roots (renamed to `cluster.sls`), and apply to all NiFi servers.
1. Put the `certificates_pillar.example` file in pillar roots (renamed to `certificates.sls`), and apply to all NiFi servers.
1. Fill out the `certificates.sls` pillar file with either your CA, intermediate CA or a self-signed CA cert, following the example format.

   Instructions on generating a cert using the NiFi TLS toolkit are [here](https://nifi.apache.org/docs/nifi-docs/html/toolkit-guide.html#standalone)
   
   Here is an example command to create a self-signed CA cert to be used when generating the cluster node certificates:
   
   `./tls-toolkit.sh standalone -n nifi-ca -o .`
   
   This will generate a new folder in the current folder named `nifi-ca`. 
   
   In there you'll find `nifi-cert.pem` and `nifi-key.key`. These are what you need to put into the `certificates.sls` pillar file, into `ca_cert` and `ca_key`, respectively.
1. The following mine function on all NiFi servers. Preferably set via minion config.

```
mine_functions:
  private_ip:
    mine_function: network.ip_addrs
    cidr: <CIDR range of your network>
```

## Configuration

Configuration of the formula is done through the `config.yaml` file. Each of the state files that take part in either the installation, configuration, or maintenance of NiFi have a section in that file, and each section has some options that can be tuned.

## Clustering

Clustering your NiFi servers can be set up manually in the `config.yaml` file, or you can use AWS EC2 instance user data to do it. 

The following lines can be added to user data to facilitate this:
```
cluster=<arbitrary name>
type=<embedded or external (embedded is default)>
```

As an example:
```
cluster=central-logging
type=embedded

# you can also comment them if needed
#cluster=central-logging
#type=embedded
```

Those two values are parsed out and stored in pillar:
1. nifi:cluster:name
1. nifi:cluster:type

Existence of the pillar value `nifi:cluster` is what causes the server to be clustered with other NiFi servers that have the same cluster name. In the example above, all NiFi servers where the pillar value `nifi:cluster:name` equals `central-logging` will be clustered together to run the same flow.

The `cluster.yaml` file has code that runs when this pillar value is found. It uses the Salt Mine to find all the other NiFi servers that have the same cluster name, and builds a list of them that is fed into the `nifi.properties` file and `zookeeper.properties` files to connect the servers together.

When the `type` is `embedded`, the embedded zookeeper server is enabled and is fed the connect string that is determined by the logic in the `cluster.yaml` file.



