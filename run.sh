#!/bin/bash

id_rsa=$3

source ansible_env

ansible-playbook -i ./hosts ec2.yml -vvvv

echo "Waiting for server to boot up in order to ssh..."

sleep 30

exit

#export ANSIBLE_HOST_KEY_CHECKING=False

#ansible-playbook -i ec2.py provision_aws.yml --private-key="${id_rsa}" -vvvv -u ubuntu -t deploy
#ansible-playbook -i ec2.py provision_aws.yml --private-key="${id_rsa}" -vvvv -u ubuntu -t configure

#ansible-playbook -i ec2.py tests.yml --private-key="${id_rsa}" -vvvv -u ubuntu -t testenv

