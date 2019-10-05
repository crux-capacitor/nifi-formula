{% import_yaml slspath~'/config.yaml' as nifi %}

include:
  - formula.nifi.user
  - formula.nifi.install
  - formula.nifi.config
  - formula.nifi.service

extend:
  "Manage NiFi Service":
    service:
      - listen:
        - file: "Manage NiFi Config Files"
{%- if nifi.cluster.enabled and nifi.cluster.type == "embedded" %}
        - file: "Manage Zookeeper Properties File"
        - file: "Manage Zookeeper Id File"
{%- endif %}