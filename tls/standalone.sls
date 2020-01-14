{% import_yaml 'formula/nifi/config.yaml' as nifi %}
{% set version = nifi.install.version %}
{% set output_path = '/opt/nifi/tls/'~grains['fqdn'] %}

include:
  - formula.nifi.toolkit

"Manage NiFi TLS Directory":
  file.directory:
    - name: /opt/nifi/tls
    - user: {{ nifi.user.name }}
    - group: {{ nifi.user.name }}
    - require_in:
      - file: "Manage CA Certificate"
      - file: "Manage CA Key"
      - cmd: "Run NiFi TLS Toolkit Standalone Mode"

"Manage CA Certificate":
  file.managed:
    - name: /opt/nifi/tls/nifi-cert.pem
    - user: {{ nifi.user.name }}
    - group: {{ nifi.user.name }}
    - mode: 600
    - contents_pillar: nifi:certificates:ca_cert

"Manage CA Key":
  file.managed:
    - name: /opt/nifi/tls/nifi-key.key
    - user: {{ nifi.user.name }}
    - group: {{ nifi.user.name }}
    - mode: 600
    - contents_pillar: nifi:certificates:ca_key

"Run NiFi TLS Toolkit Standalone Mode":
  cmd.run:
    - names:
      - ./tls-toolkit.sh standalone -n {{ grains['fqdn'] }} -o /opt/nifi/tls/:
        - creates: {{ output_path }}/keystore.jks
      - grep nifi.security.keystorePasswd {{ output_path }}/nifi.properties | awk -F"=" '{print $2}' > {{ output_path }}/keystore_pass:
        - onchanges:
          - cmd: ./tls-toolkit.sh standalone -n {{ grains['fqdn'] }} -o /opt/nifi/tls/
      - grep nifi.security.truststorePasswd {{ output_path }}/nifi.properties | awk -F"=" '{print $2}' > {{ output_path }}/truststore_pass:
        - onchanges:
          - cmd: ./tls-toolkit.sh standalone -n {{ grains['fqdn'] }} -o /opt/nifi/tls/
    - cwd: /opt/nifi/nifi-toolkit-{{ version }}/bin/
    - runas: {{ nifi.user.name }}
    - require:
      - sls: formula.nifi.toolkit
      - file: "Manage CA Certificate"
      - file: "Manage CA Key"
