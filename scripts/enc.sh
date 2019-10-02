#!/bin/bash
#
# Helper script to encode Ansible vault secrets
# Args:
#   <secret_to_encode>
#
# Example: scripts/enc.sh "passw0rd"
#

ansible-vault encrypt_string $1 --vault-password-file vault.key
