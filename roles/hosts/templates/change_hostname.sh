#!/bin/bash
export host_name_full=`curl http://169.254.169.254/latest/meta-data/hostname`
echo "${host_name}" > /etc/hostname
echo "127.0.0.1 localhost ${host_name}" > /etc/hosts

