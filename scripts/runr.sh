#!/bin/bash
#
# Helper script to run Ansible playbooks remotely
# Args:
#   <remote-host>
#   <remote-dir>
#   <playbook>
#   <inventory>
#   <extra-vars> (optional)
#
# Example: scripts/rrun.sh my-remote-host /tmp bringup/main localhost,
#
HOST=$1
RDIR=$2
BOOK=`basename ${PWD}`
if [[ ${3: -4} == ".yml" ]]
then
  PLAY=$3
else
  PLAY=$3.yml
fi
INVY=$4

echo "Ensure remote directory exists : ${RDIR}"
ssh ${HOST} "mkdir -p ${RDIR}"
echo "Sync playbook with remote host : ${HOST}"
rsync -r .. ${HOST}:${RDIR}
echo "Clean remote logs for staging  : ${BOOK}"
ssh ${HOST} "rm -rf /tmp/power-ops ${RDIR}/${BOOK}/*.retry ~/.ansible; rm -f ${RDIR}/${BOOK}/run.out; touch ${RDIR}/${BOOK}/run.out"
echo "Execute remote playbook        : ${PLAY}"
ssh -f ${HOST} "sh -c 'cd ${RDIR}/${BOOK}; nohup ansible-playbook -i ${INVY} ${@:5} ${PLAY} --vault-password-file state/vault.key >run.out 2>&1 &'"
echo "Show remote output             : run.out"
ssh ${HOST} "sh -c 'cd ${RDIR}/${BOOK}; tail -n 10000 -f run.out'"
