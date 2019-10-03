{% import_yaml slspath~'/config.yaml' as nifi %}
{% set version = nifi.install.version %}

include:
  - formula.nifi.user
  
"Extract NiFi Toolkit":
  archive.extracted:
    - name: /opt/nifi/
    - source: salt://{{ slspath }}/installers/nifi-toolkit-{{ version }}-bin.tar.gz
    - user: nifi
    - group: nifi
    - keep_source: False
    - if_missing: /opt/nifi/nifi-{{ version }}/bin/nifi-toolkit.sh
    - require:
      - sls: formula.nifi.user