#!/bin/bash
# Author - John Knepper
# Notes  - Simple driver to spin up various playbooks on EC2.
# Keep in mind that you can override any variables using the ansible CLI flag --extra-vars.
# PRIVATE KEY = PEM root key that exists in AWS IAM, and you wish to provision as the instance's
# root key.
# ROLE = (openvpn|kube-master|etc)
# TAG_NAME = (openvpn|kube-master|whatever)
# SKIP (bool) = true or false. If true, will not spin up a new EC2 instance and will provision it 
# with the play book specified as ROLE.

if [  "$#" -ne 3 ]; then
echo <<EOF
USAGE:
  ./run.sh <private key> <role (ex. openvpn or kube-master)> <tag name (ex openvpn or kube-master)> <true|false>
EOF

fi

export id_rsa=$1

source ansible_env

export ROLE=$2
export TAG_NAME=$3
export TAG_ENV=${ENVIRONMENT}
export SKIP=$4

if [ "$SKIP" == "true" ]; then
    ansible-playbook -i ./hosts ec2.yml -vvvvv -u ubuntu --tags "configure,deploy"

    echo "Waiting for server to boot up in order to ssh..."

    sleep 30

fi

export ANSIBLE_HOST_KEY_CHECKING=False

export SED_NAME=`echo $TAG_NAME | sed 's/-/_/g'`
export SED_ENV=`echo $TAG_ENV | sed 's/-/_/g'`

ansible-playbook ${ROLE}.yml -i ec2.py \
                             -u ubuntu \
                             --private-key=$id_rsa \
                             -vvvv \
                             --extra-vars "tag_name=${SED_NAME} tag_environment=${SED_ENV}" \
                             --tags "configure,deploy"

