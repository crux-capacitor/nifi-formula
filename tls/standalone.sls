{% import_yaml 'formula/nifi/config.yaml' as nifi %}
{% set version = nifi.install.version %}

include:
  - formula.nifi.toolkit

"Run NiFi TLS Toolkit Standalone Mode":
  cmd.run:
    - name: ./tls-toolkit.sh standalone -n {{ grains['fqdn'] }} -o /opt/nifi/nifi-{{ version }}/conf/
    - cwd: /opt/nifi/nifi-toolkit-{{ version }}/bin/
    - creates: /opt/nifi/nifi-{{ version }}/conf/{{ grains['fqdn'] }}/keystore.jks
    - require:
      - sls: formula.nifi.toolkit
