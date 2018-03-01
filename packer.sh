#!/bin/bash
# Author - John Knepper
# Date   - January 24th, 2018

# USAGE:
# ./packer.sh <ROLE - base-ami | openvpn | etc> <instance type> </packer/binary/path>

export RUN_LIST="configure,deploy"
export ROLE="$1"
export PACKER_PATH="${3:-/usr/local/bin/}"

if [ "$#" -ne 2 ]; then

  echo "Usage: `basename $0` <ansible role> <instance type> [packer path]"
  exit $E_BADARGS
    
fi 

${PACKER_PATH}packer build \
    -var "aws_access_key=${AWS_ACCESS_KEY_ID}" \
    -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
    -var "RUN_LIST=${RUN_LIST}" \
    -var "ROLE=${ROLE}" \
    -var "tag_name=${TAG_NAME}" \
    -var "tag_environment=${TAG_ENVIRONMENT}" \
    -var "region=${REGION}" \
    -var "source_ami=${AMI_ID}" \
    -var "instance_type=${2}" \
    -var "security_group_id=${SG_ID}" \
    -var "subnet_id=${PRIVATE_SUBNET_ID}" \
    -var "IAM_ROLE=${IAM_ROLE}" \
    ./packer/${ROLE}.json
