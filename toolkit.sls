{% import_yaml slspath~'/config.yaml' as nifi %}
{% set version = nifi.install.version %}

include:
  - formula.nifi.user
  
"Extract NiFi Toolkit":
  archive.extracted:
    - name: /opt/nifi/
    - source: 
      #- http://apache.mirrors.pair.com/nifi/{{ version }}/nifi-toolkit-{{ version }}-bin.zip
      - salt://{{ slspath }}/installers/nifi-toolkit-{{ version }}-bin.zip
    - user: nifi
    - group: nifi
    - skip_verify: True
    - keep_source: False
    - trim_output: 10
    - if_missing: /opt/nifi/nifi-{{ version }}/bin/nifi-toolkit.sh
    - require:
      - sls: formula.nifi.user