#!/bin/bash
# Author - John Knepper
# Notes  - Simple driver to spin up various playbooks on EC2.
# Keep in mind that you can override any variables using the ansible CLI flag --extra-vars.
# PRIVATE KEY = PEM root key that exists in AWS IAM, and you wish to provision as the instance's
# root key.
# ROLE = (openvpn|kube-master|etc)
# TAG_NAME = (openvpn|whatever)
# SKIP (bool) = true or false. If true, will not spin up a new EC2 instance and will provision it 
# with the play book specified as ROLE.

if [  "$#" -ne 5 ]; then
echo "
USAGE:

  ./run.sh \$PRIVATE_KEY_PATH \$ROLE \$TAG_NAME \$BOOL
 
  \$PRIVATE_KEY_PATH - the path to your private key PEM file downloades when you created an IAM key in AWS.
  \$ROLE - the role (play) you wish to run; under ./roles/
  \$TAG_NAME - the name you wish to tag your instance with; this will automatically prefix the ENVIRONMENT
    variable set in the ansible_env file.
  \$ENVIRONMENT - the environment; this gets joined with tag name for dynamic inventory.
  \$TASK - the task to run; ex 'logs'

EXAMPLE:

  ./run-task.sh ~/.ssh/production-vpc-us-east-1.pem openvpn openvpn development logs
   
"

exit

fi

export id_rsa=$1

source ansible_env

export ROLE=$2
export TAG_NAME=$3
export TAG_ENV=$4

export ANSIBLE_HOST_KEY_CHECKING=False

export SED_NAME=`echo $TAG_NAME | sed 's/-/_/g'`
export SED_ENV=`echo $TAG_ENV | sed 's/-/_/g'`

ansible-playbook ${ROLE}.yml -i ec2.py \
                             -u ubuntu \
                             --private-key=$id_rsa \
                             -vvvv \
                             --extra-vars "tag_name=${SED_NAME} tag_environment=${SED_ENV} env=$4" \
                             --tags "${5}"

