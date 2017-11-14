#!/bin/bash

systemctl stop kubelet | true

rm -rf /etc/kubernetes/manifests | true
rm -rf /var/lib/etcd | true

kubeadm reset | true

JOIN_CMD=`kubeadm init --pod-network-cidr={{kubernetes_pod_cidr}} | grep "kubeadm join" | sed 's/^ *//g'`
echo ${JOIN_CMD} > /tmp/kubey-join-cmd.txt

mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml

KUBE_JOIN_TOKEN=`kubeadm token create --groups system:bootstrappers:kubeadm:default-node-token --ttl 0`

echo "Non-expiring join token: $KUBE_JOIN_TOKEN" > /tmp/kube-forever-token

kubectl create configmap \
        kube-admin-{{kubernetes_environment}} \
        --from-file=/etc/kubernetes/admin.conf


