include:
  - formula.nifi.install

"Manage Nifi Service":
  service.running:
    - name: nifi
    - enable: True
    - require:
      - sls: formula.nifi.install
