#!/bin/bash


# Clean up in case this is a re-run
rm -rf /etc/kubernetes/

systemctl stop kubelet | true

# pull down non-expiring join token for join command below.
# aws s3 cp s3://{{s3_bucket_name}}/kubernetes-join-{{kube_master_tag}}-{{kubernetes_environment}}.txt .
# export KUBEADM_JOIN_TOKEN=`cat kubernetes-join-{{kube_master_tag}}-{{kubernetes_environment}}.txt`

# Pull down sha256 hash from s3 for kubeadm join command below
aws s3 cp s3://{{s3_bucket_name}}/kube-forever-token-{{kube_master_tag}}-{{kubernetes_environment}}.txt .
export KUBEADM_FOREVER_TOKEN=`cat kube-forever-token-{{kube_master_tag}}-{{kubernetes_environment}}.txt`

aws s3 cp s3://{{s3_bucket_name}}/kube-sha256-token-{{kube_master_tag}}-{{kubernetes_environment}}.txt .
export KUBEADM_SHA256_TOKEN=`cat kube-sha256-token-{{kube_master_tag}}-{{kubernetes_environment}}.txt`

# Join this node based on submitted token and sha
kubeadm join \
        --token ${KUBEADM_FOREVER_TOKEN} \
        {{ kube_master_ip }}:6443 \
        --discovery-token-ca-cert-hash sha256:${KUBEADM_SHA256_TOKEN}

