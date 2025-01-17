{% import_yaml slspath~'/config.yaml' as nifi %}
{% set version = nifi.install.version %}

include:
  - formula.nifi.user

"Install Java":
  pkg.installed:
    - name: {{ nifi.install.java }}

"Extract NiFi Archive":
  archive.extracted:
    - name: /opt/nifi/
    - source:
      #- http://us.mirrors.quenda.co/apache/nifi/{{ version }}/nifi-{{ version }}-bin.zip
      - salt://{{ slspath }}/installers/nifi-{{ version }}-bin.zip
    - user: nifi
    - group: nifi
    - skip_verify: True
    - keep_source: False
    - trim_output: 10
    - if_missing: /opt/nifi/nifi-{{ version }}/bin/nifi.sh
    - require:
      - sls: formula.nifi.user
      - pkg: "Install Java"

# "Install NiFi":
#   cmd.run:
#     - name: /opt/nifi/nifi-{{ version }}/bin/nifi.sh install && systemctl enable nifi
#     - onchanges:
#       - archive: "Extract NiFi Archive"
