include:
  - formula.nifi.install

"Manage NiFi Service":
  service.running:
    - name: nifi
    - enable: True
    - require:
      - sls: formula.nifi.install
