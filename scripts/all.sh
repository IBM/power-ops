#!/bin/bash
#
# Helper script to run Ansible
# Args:
#   <playbook>
#   <inventory>
#   <extra-vars> (optional)
#
# Example: scripts/run.sh bringup/main localhost,
#

# clean logs
rm -rf /tmp/ansible.facts/ /tmp/ansible.log *.retry

# check for arguments
errata=0
retcode=0
if [ $# -gt 1 ]
then
	errata=1
elif [ $# -eq 1 ]
then
    if [ $1 == "nutanix" ]
    then
    	# execute bringup with mechanism nutanix
		ansible-playbook -i localhost, bringup/bringup.yml --extra-vars "provisioner=nutanix" --vault-password-file state/vault.key
		if [ $? -ne 0 ]
		then
			echo "Bringup failed - exiting"
			exit 1
		fi
    else
    	errata=1
    fi
fi

if [ $errata -eq 0 ]
then
	# execute remaining playbooks
	ansible-playbook -i inventory/hosts bringup/prepare.yml --vault-password-file state/vault.key
	if [ $? -ne 0 ]
	then
		echo "Prepare failed - exiting"
		exit 1
	fi
	ansible-playbook -i inventory/hosts build/main.yml --vault-password-file state/vault.key
	if [ $? -ne 0 ]
	then
		echo "Build failed - exiting"
		exit 1
	fi
	ansible-playbook -i inventory/hosts deploy/main.yml --vault-password-file state/vault.key
	if [ $? -ne 0 ]
	then
		echo "Deploy failed - exiting"
		exit 1
	fi
else
	echo "Only one argument supported: bringup mechanism to use"
	echo "Supported values:"
	echo "   nutanix - uses Nutanix infrastructure to create VMs"
fi

