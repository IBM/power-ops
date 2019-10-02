#!/bin/bash
#
# Helper script to run Ansible playbooks
# Args:
#   <playbook>
#   <inventory>
#   <extra-vars> (optional)
#
# Example: scripts/run.sh bringup/main localhost,
#
rm -rf /tmp/ansible.facts/ /tmp/ansible.log *.retry
if [[ ${1: -4} == ".yml" ]]
then
  PLAY=$1
else
  PLAY=$1.yml
fi
ansible-playbook -i ${2} ${@:3} $PLAY --vault-password-file state/vault.key
