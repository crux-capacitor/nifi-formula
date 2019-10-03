"Manage Nifi Group":
  group.present:
    - name: nifi

"Manage Nifi User":
  user.present:
    - name: nifi
    - home: /opt/nifi
    - createhome: True
    - groups:
      - nifi
    - require:
      - group: "Manage Nifi Group"