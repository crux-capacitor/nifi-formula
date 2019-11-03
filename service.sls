{% import_yaml slspath~'/config.yaml' as nifi %}

include:
  - formula.nifi.install

"Manage NiFi Service":
  file.managed:
    - name: /etc/systemd/system/nifi.service
    - source: salt://{{ slspath }}/files/nifi.service
    - template: jinja
    - context:
        version: {{ nifi.install.version }}
        user: {{ nifi.user }}
        group: {{ nifi.group }}
    - require:
      - sls: formula.nifi.install
  service.running:
    - name: nifi
    - enable: True
    - require:
      - file: "Manage NiFi Service"
