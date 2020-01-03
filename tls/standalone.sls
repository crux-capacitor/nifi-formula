{% import_yaml 'formula/nifi/config.yaml' as nifi %}
{% set version = nifi.install.version %}
{% set output_path = '/opt/nifi/tls/'~grains['private_ip'] %}

include:
  - formula.nifi.toolkit

"Manage NiFi TLS Directory":
  file.directory:
    - name: /opt/nifi/tls
    - user: {{ nifi.user.name }}
    - group: {{ nifi.user.name }}
    - require_in:
      - cmd: "Run NiFi TLS Toolkit Standalone Mode"

"Run NiFi TLS Toolkit Standalone Mode":
  cmd.run:
    - names:
      - ./tls-toolkit.sh standalone -n {{ grains['private_ip'] }} -o /opt/nifi/tls/:
        - creates: {{ output_path }}/keystore.jks
      - grep nifi.security.keystorePasswd {{ output_path }}/nifi.properties | awk -F"=" '{print $2}' > {{ output_path }}/keystore_pass:
        - onchanges:
          - cmd: ./tls-toolkit.sh standalone -n {{ grains['private_ip'] }} -o /opt/nifi/tls/
      - grep nifi.security.truststorePasswd {{ output_path }}/nifi.properties | awk -F"=" '{print $2}' > {{ output_path }}/truststore_pass:
        - onchanges:
          - cmd: ./tls-toolkit.sh standalone -n {{ grains['private_ip'] }} -o /opt/nifi/tls/
    - cwd: /opt/nifi/nifi-toolkit-{{ version }}/bin/
    - runas: {{ nifi.user.name }}
    - require:
      - sls: formula.nifi.toolkit

"Extract Public Key":
  cmd.run:
    - name: keytool -exportcert -alias nifi-key -rfc -keystore {{ output_path }}/keystore.jks -file {{ output_path }}/public.pem
    - stdin: __slot__:salt:file.read({{ output_path}}/keystore_pass)
    - creates: {{ output_path }}/public.pem
    - onchanges:
      - cmd: "Run NiFi TLS Toolkit Standalone Mode"

"Trigger Mine Update":
  module.run:
    - name: mine.update
    - onchanges:
      - cmd: "Extract Public Key"

{% for server, key in salt.mine.get('role:nifi', 'nifi_public_key', tgt_type='grain').items() %}
{%   if server != grains['id'] %}

"Manage Public Key File - {{ server }}":
  file.managed:
    - name: /opt/nifi/tls/{{ server }}_public.pem
    - user: {{ nifi.user.name }}
    - group: {{ nifi.user.name }}
    - contents: {{ key.split('\n')|json }}
    - mode: 600
    - require:
      - module: "Trigger Mine Update"

"Import Public Key File - {{ server }}":
  cmd.run:
    - name: keytool -import -noprompt -file /opt/nifi/tls/{{ server }}_public.pem -alias nifi-key -keystore {{ output_path }}/truststore.jks -v
    - stdin: __slot__:salt:file.read({{ output_path}}/truststore_pass)
    - onchanges:
      - file: "Manage Public Key File - {{ server }}"

{%   endif %}
{% endfor %}
