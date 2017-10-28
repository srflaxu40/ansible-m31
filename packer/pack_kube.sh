#!/bin/bash
# Author - John Knepper
# Date   - Oct 28, 2017

# USAGE:
# ./pack_kube.sh  <TAG_NAME> <AWS KEY> <AWS SECRET KEY> 
#                 <REGION> <SOURCE AMI> <INSTANCE TYPE> <SECURTY GROUP ID> <SUBNET ID> <VAULT FILE PATH> <PACKER PATH> <IAM ROLE NAME>

export RUN_LIST="configure,deploy,test"
export PG_PASS="$2"
export PG_HOST="$3"
export ZK_HOST="$4"
export PACKER_PATH="${14:-/usr/local/bin/}"


${PACKER_PATH}packer build -debug \
    -var "aws_access_key=$6" \
    -var "aws_secret_key=$7" \
    -var "RUN_LIST=${RUN_LIST}" \
    -var "tag_name=$5" \
    -var "region=$8" \
    -var "source_ami=$9" \
    -var "instance_type=${10}" \
    -var "security_group_id=${11}" \
    -var "subnet_id=${12}" \
    -var "vault_file=${13}" \
    -var "IAM_ROLE=${15}" \
    "$1.json""
