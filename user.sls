{% import_yaml slspath~'/config.yaml' as nifi %}

"Manage NiFi Group":
  group.present:
    - name: {{ nifi.group.name }}

"Manage NiFi User":
  user.present:
    - name: {{ nifi.user.name }}
    - home: {{ nifi.user.home_dir }}
    - createhome: True
    - shell: /bin/false
    - groups:
      - {{ nifi.group.name }}
    - require:
      - group: "Manage NiFi Group"
