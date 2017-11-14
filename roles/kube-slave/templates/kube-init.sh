#!/bin/bash


# Clean up in case this is a re-run
rm -rf /etc/kubernetes/

systemctl stop kubelet | true

# Join this node based on submitted token and sha
kubeadm join \
        --token {{ master_join_token }} \
        {{ master_ip }}:6443 \
        --discovery-token-ca-cert-hash sha256:{{ sha_256_hash }}

# Get configmap that holds configuration for cluster interaction
# kubectl get configmap kube-admin-{{ environment }} \
#        -o yaml >> /etc/kubernetes/admin.conf

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

