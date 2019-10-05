"Manage NiFi Group":
  group.present:
    - name: nifi

"Manage NiFi User":
  user.present:
    - name: nifi
    - home: /opt/nifi
    - createhome: True
    - shell: /bin/false
    - groups:
      - nifi
    - require:
      - group: "Manage NiFi Group"