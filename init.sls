{% import_yaml slspath~'/config.yaml' as nifi %}

include:
  - formula.nifi.user
{%- if nifi.disk.enabled %}
  - formula.nifi.disk
{%- endif %}
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

{%- if nifi.cluster.enabled %}
  "Trigger NiFi Infra Update":
    event:
      - order: last
{%- endif %}
