{% import_yaml slspath~'/config.yaml' as nifi %}
{% set version = nifi.install.version %}

{% if nifi.disk.enabled %}
{%   set data_dir = nifi.disk.mount_point ~ '/nifi' %}
{% else %}
{%   set data_dir = '/opt/nifi/nifi-' ~ nifi.install.version %}
{% endif %}

include:
  - formula.nifi.install

"Manage Nifi Config Files":
  file.recurse:
    - name: /opt/nifi/nifi-{{ version }}/conf
    - source: salt://{{ slspath }}/files/
    #- exclude_pat: E@(zookeeper.properties)|(myid)|(*.tar.gz)
    - user: nifi
    - group: nifi
    - template: jinja
    - context:
        cluster: {{ nifi.cluster.enabled }}
        data_dir: {{ data_dir }}
        config: {{ nifi.config }}

