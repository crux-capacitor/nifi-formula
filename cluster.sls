{% import_yaml slspath~'/config.yaml' as nifi %}
{% set version = nifi.install.version %}
{% set nifi_servers = ['abcd', 'efgh', 'ijkl', 'mnop', 'ubuntu'] %}

{% if nifi.cluster.enabled %}

{%   if nifi.cluster.type == "embedded" %}

"Manage Zookeeper Properties File":
  file.managed:
    - name: /opt/nifi/nifi-{{ version }}/conf/zookeeper.properties
    - source: salt://{{ slspath }}/files/zookeeper.properties
    - template: jinja
    - user: nifi
    - context:
        servers: {{ nifi_servers }}

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

{%   else %}

"External Clustering Is Not Yet Supported":
  test.fail_without_changes

{%   endif %} # end if-block testing type == "embedded"

{% endif %} # end if-block testing cluster.enabled