#!/bin/bash


# Clean up in case this is a re-run
rm -rf /etc/kubernetes/

systemctl stop kubelet | true

# pull down non-expiring join token for join command below.
aws s3 cp s3://{{s3_bucket_name}}/kubernetes-join-{{kubernetes_environment}}.txt .
export KUBEADM_JOIN_TOKEN=`cat kubernetes-join-{{kubernetes_environment}}.txt`

# Pull down sha256 hash from s3 for kubeadm join command below
aws s3 cp s3://{{s3_bucket_name}}/kube-forever-token-{{kubernetes_environment}}.txt .
export KUBEADM_SHA256_TOKEN=`cat kube-forever-token-{{kubernetes_environment}}.txt`

# Join this node based on submitted token and sha
kubeadm join \
        --token ${KUBEADM_JOIN_TOKEN} \
        {{ kube_master_ip }}:6443 \
        --discovery-token-ca-cert-hash sha256:${KUBEADM_SHA256_TOKEN}

# This is not totally necessary unless you plan on interacdting with your kube cluster.
aws s3 cp s3://{{ s3_bucket_name }}/kube-admin-{{ kubernetes_environment }} /etc/kubernetes/admin.conf

chmod 755 /etc/kubernetes/admin.conf

# Setup for root
mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# Setup for {{ ansible_ssh_user }}
mkdir -p /home/{{ansible_ssh_user}}/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown {{ ansible_ssh_user }}:{{ ansible_ssh_user}} /home/{{ ansible_ssh_user }}/.kube/config

