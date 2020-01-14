{% import_yaml slspath~'/config.yaml' as nifi %}
{% set version = nifi.install.version %}

"Tail NiFi App Log":
  cmd.run:
    - name: 'tail -100 /opt/nifi/nifi-{{ version }}/logs/nifi-app.log'
