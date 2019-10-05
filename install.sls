{% import_yaml slspath~'/config.yaml' as nifi %}
{% set version = nifi.install.version %}

include:
  - formula.nifi.user
{%- if nifi.disk.enabled %}
  - formula.nifi.disk
{%- endif %}

"Extract NiFi Archive":
  archive.extracted:
    - name: /opt/nifi/
    - source: salt://{{ slspath }}/installers/nifi-{{ version }}-bin.tar.gz
    - user: nifi
    - group: nifi
    - keep_source: False
    - if_missing: /opt/nifi/nifi-{{ version }}/bin/nifi.sh
    - require:
      - sls: formula.nifi.user

"Install NiFi":
  cmd.run:
    - name: /opt/nifi/nifi-{{ version }}/bin/nifi.sh install && systemctl enable nifi
    - onchanges:
      - archive: "Extract NiFi Archive"
