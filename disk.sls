{% import_yaml slspath~'/config.yaml' as nifi %}

# Check if the 2nd disk has already been saved to the minion data store.
# If not, run the first block to determine the device name of this disk, and then
# save it to the data store. This is done because the command below only works once, before 
# the disk has been formatted.
# If it has been saved to the data store, just get the device name from there.
{% if not salt.data.get('data_disk') %}
{%   set data_disk = "/dev/" ~ salt.cmd.run("lsblk -d -s | grep disk | awk '{print $1}'", python_shell=True) %}
{%   do salt.data.update('data_disk', data_disk) %}
{% else %}
{%   set data_disk = salt.data.get('data_disk') %}
{% endif %}

{% set mount_point = nifi.disk.mount_point %}

include:
  - formula.nifi.user

"Format Nifi Data Disk":
  blockdev.formatted:
    - name: {{ data_disk }}
    - fs_type: ext4

"Mount Nifi Data Disk":
  mount.mounted:
    - name: {{ mount_point }}
    - device: {{ data_disk }}
    - fstype: ext4
    - mkmnt: True
    - persist: True
    - opts: rw,seclabel,relatime,data=ordered
    - dump: 0
    - pass_num: 0
    - mount: True
    - require:
      - blockdev: "Format Nifi Data Disk"

"Manage Mounted Nifi Directories":
  file.directory:
    - name: {{ mount_point }}/nifi/lib
    - make_dirs: True
    - user: nifi
    - group: nifi
    - dir_mode: 755
    - file_mode: 644
    - require:
      - sls: formula.nifi.user
      - mount: "Mount Nifi Data Disk"
