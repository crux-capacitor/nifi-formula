{% import_yaml slspath~'/config.yaml' as nifi %}
{% set version = nifi.install.version %}

# If the external disk option is enabled, set data_dir to the configured mount point + /nifi. (Ex: /mnt/nifi/)
# Otherwise, set it to the local install directory (Ex: /opt/nifi/nifi-1.9.2/)
# This will configure the flow diagram, provenance, and other disk-heavy files to be kept on the
# mounted disk, if there is one.
{% if nifi.disk.enabled %}
{%   set data_dir = nifi.disk.mount_point ~ '/nifi' %}
{% else %}
{%   set data_dir = '/opt/nifi/nifi-' ~ nifi.install.version %}
{% endif %}

# Set memory allocated to NiFi to 66% of the system's available memory
{% set memory = (salt.grains.get('mem_total') / 3 * 2 / 1000) | round(0,'floor') | int %}
{% if memory < 1 %}
{%   set mem_size = '128m' %}
{% else %}
{%   set mem_size = memory ~ 'g' %}
{% endif %}

include:
  - formula.nifi.install
{%- if nifi.config.tls.enabled %}
  - formula.nifi.tls.{{ nifi.config.tls.type }}
{%- endif %}
{%- if nifi.cluster.enabled %}
  - formula.nifi.cluster
{%- endif %}
{%- if nifi.disk.enabled %}
  - formula.nifi.disk
{%- endif %}

"Manage NiFi Config Files":
  file.recurse:
    - name: /opt/nifi/nifi-{{ version }}/conf
    - source: salt://{{ slspath }}/files/
    - exclude_pat: E@(zookeeper.properties)|(myid)|(security-limits.conf)
    - user: nifi
    - group: nifi
    - template: jinja
    - context:
        version: {{ version }}
        cluster: {{ nifi.cluster|json }}
        data_dir: {{ data_dir }}
        config: {{ nifi.config|json }}
        mem_size: {{ mem_size }}
{%- if nifi.disk.enabled %}
    - require:
      - sls: formula.nifi.disk
{%- endif %}

{% if nifi.config.best_practices.enabled %}

"Manage Security Limits Config":
  file.managed:
    - name: /etc/security/limits.conf
    - source: salt://{{ slspath }}/files/security-limits.conf

"Disable Swappiness":
  sysctl.present:
    - name: vm.swappiness
    - value: 0

"Set TCP Socket Time-Wait":
  sysctl.present:
    - name: net.ipv4.netfilter.ip_conntrack_tcp_timeout_time_wait
    - value: 1

{% endif %}