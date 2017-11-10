#!/bin/bash

id_rsa=$1

source ansible_env

export TAG_NAME=openvpn
export TAG_ENV=development

ansible-playbook -i ./hosts ec2.yml -vvvvv -u ubuntu --tags "configure,deploy"

echo "Waiting for server to boot up in order to ssh..."

sleep 30

export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook openvpn.yml -i ec2.py \
                             -u ubuntu \
                             --private-key=$id_rsa \
                             -vvvv \
                             --extra-vars "tag_name=${TAG_NAME} tag_environment=${TAG_ENV}" \
                             --tags "configure,deploy"
