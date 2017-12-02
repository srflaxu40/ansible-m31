#!/bin/bash
# Author - John Knepper
# Date   - Nov 30th, 2017

# USAGE:
# ./pack_kube.sh <kube template JSON file>

source ../ansible_env

export PACKER_PATH="${14:-/usr/local/bin/}"


${PACKER_PATH}packer build \
    "${1}"
