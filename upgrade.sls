{% import_yaml slspath~'/config.yaml' as nifi %}
{% set version = nifi.install.version %}

include:
  - formula.nifi.user

"Stop NiFi Service":
  service.dead:
    - name: nifi

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
      - service: "Stop NiFi Service"

"Install NiFi":
  cmd.run:
    - name: /opt/nifi/nifi-{{ version }}/bin/nifi.sh install && systemctl enable nifi
    - onchanges:
      - archive: "Extract NiFi Archive"

"Start NiFi Service":
  service.running:
    - name: nifi
    - enable: True
