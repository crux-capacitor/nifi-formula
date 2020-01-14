{% import_yaml slspath~'/config.yaml' as nifi %}
{% set version = nifi.install.version %}

{% if nifi.cluster.enabled %}

"Mine Update":
  module.run:
    - name: mine.update

{% for host in nifi.cluster.hosts %}

"Manage Host Entry - {{ host.name }} -> {{ host.ip }}":
  host.present:
    - ip: {{ host.ip }}
    - names:
      - {{ host.name }}

{% endfor %}

{%   if nifi.cluster.type == "embedded" %}

"Manage Zookeeper Properties File":
  file.managed:
    - name: /opt/nifi/nifi-{{ version }}/conf/zookeeper.properties
    - source: salt://{{ slspath }}/files/zookeeper.properties
    - template: jinja
    - user: nifi
    - context:
        servers: {{ nifi.cluster.zk_servers|json }}
    - onchanges_in:
      - event: "Trigger NiFi Infra Update"

"Manage Zookeeper Id File":
  file.managed:
    - name: /opt/nifi/nifi-{{ version }}/state/zookeeper/myid
    - source: salt://{{ slspath }}/files/myid
    - makedirs: True
    - template: jinja
    - user: nifi
    - context:
        zk_props_file: /opt/nifi/nifi-{{ version }}/conf/zookeeper.properties
    - require:
      - file: "Manage Zookeeper Properties File"
    - onchanges_in:
      - event: "Trigger NiFi Infra Update"

{%   else %}

"External Clustering Is Not Yet Supported":
  test.fail_without_changes

{%   endif %} # end if-block testing type == "embedded"

"Trigger NiFi Infra Update":
  event.send:
    - name: infra/update/nifi
    - data:
        role: nifi

{% endif %} # end if-block testing cluster.enabled
