# ansible-m31

Run, pack, and provision your infrastructure with Ansible code against Amazon's Cloud (AWS).
Test your code on-the-fly with ansible-kitchen, and docker for mac.


# Development Setup

* This repo expects you've installed [Homebrew](https://brew.sh/).
* Install rbenv with the instructions below.
* This repo expects that you have installed [Docker for Mac](https://docs.docker.com/docker-for-mac/install/).
* Please also setup your [aws configuration](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).

## Setting up your local virtualenv
1. Install [PyEnv](https://github.com/pyenv/pyenv#homebrew-on-mac-os-x)
   - Now install python v2.7.10
     `pyenv install 2.7.10`

2. Install virtualenv
  - `brew install pyenv-virtualenv`
  * Add content to your ~/.bash_profile (one-time only)
```
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

3. Activate project
  - `pyenv activate ansible`

* You should now be in the ansible project.  Install your pip modules (one-time only):
```
pip install boto
pip install ansible
pip install awscli
```

## Roles:

* No network arch. (VPCs, subnets, etc) are created by these playbooks.  These playbooks expect you have a VPC created with existing subnets.  In order for certain roles to work (like openvpn), you must have a public subnet connected to your internet gateway (IGW) via a route table.  This is necessary for instances created by the ec2.yml playbook that require a public subnet; a public subnet infers instances will have public IPs and direct access to your VPC's Internet Gateway (IGW).

### Really Important (ansible_env):
* The _*ansible_env*_ file sets environment variables that are required to be changed; this is super important for you to customize to your own values.  Others that exist, but do not have to be changed (defaults) are inside the standard vars directory for a role `roles/<role name>/vars/main.yml`.
  - These vars can also be overridden on the command line or inside the run.sh script by adding the `--extra-args` argument.
  - The s3 bucket you specify in this file for `S3_BUCKET_NAME` should have proper access policies restricting only to users that are authenticated in your AWS account.  Although users cannot interact with your kubernetes cluster without a VPN anyway.
  - Also, ensure your instances are spun up with proper IAM access to s3.  The Kubernetes playbooks utilize S3 to access generated configuration the the kube-master.yml playbook creates.  It also requires the ability to provision new instances in EC2.  Note that this is set in ansible_env via the `IAM_ROLE` environment variable.
* Important - this has only been tested on the base Ubuntu AMI for 16.04 in us-east-1 (ami-cd0f5cb6).  Running it on
  other AMIs may require modifications / forking this repository.
* This supports only the AWS cloud.
* Example Route Table for a Public Subnet:
![Alt text](/images/public_subnet.png?raw=true "Example Route Table.")

* Example Security Group that gives access to 443 for VPN access, ssh access to the VPN, and also allows traffic to it from an internal security group:
![Alt text](/images/vpn_sg.png?raw=true "Example VPN Security Group.")

* `run.sh` - This is meant to be run _after_ setting your vars in `ansible_env`.
  - Please note that this spins up an ec2 instance first, and then provisions it with the playbook specified in the CML.
  - Please set your AWS keys in your credentials keychain as noted above in Development Setup.
  - Also, please update `ansible_env` to values specific to your VPC, Subnet (must be public for a VPN), Security Groups,
    IAM Role, etc...  The example values in the `ansible_env` will not work for you.
```
USAGE:

  ./run.sh $PRIVATE_KEY_PATH $ROLE $TAG_NAME $BOOL
 
  $PRIVATE_KEY_PATH - the path to your private key PEM file downloades when you created an IAM key in AWS.
  $ROLE             - the role (play) you wish to run; under ./roles/
  $TAG_NAME         - the name you wish to tag your instance with; this will automatically prefix the ENVIRONMENT
    variable set in the ansible_env file.
  $BOOL             - true or false.  Spin up a new EC2 instance or provision the old one using ansible AWS EC2 tagging in your playbook.

EXAMPLE:

  ./run.sh ~/.ssh/production-vpc-us-east-1.pem kube-master kube-master-test true
  
  This will create a brand new EC2 instance of type specified in ansible_env, and tagged kube-master-development with the root key named production-vpc-us-east-1 in AWS IAM, and provisioned with the kube-master.yml playbook specified with $ROLE.
```
* Please note that specifying *false* as the BOOL argument expects that an instance exists with the tag name and environment variable (inside ansible_env).  This then provisions that instance with the plays designated by ROLE.
* Here is an example of how ansible uses the tag name and environment along with dynamic inventory to provision the instance:
```
---
# file: packer/openvpn.yml
- name: Configure and deploy kube node
  hosts: tag_Name_{{ tag_name }}_{{ tag_environment }}
  remote_user: ubuntu
  become: yes 
  gather_facts: False
  roles:
    - python
    - hosts
    - openvpn
```

## OpenVPN:
* Before running the openvpn provisioning, be sure that you set the following environment variables:
```
SG_ID
SUBNET_ID (must be a public subnet with Internet Gateway Access)
TAG_NAME (ex. openvpn)
TAG_ENV (ex. development)
AMI_ID
IAM_ROLE
SSH_KEY
REGION
ORG_COUNTRY=US
ORG_PROVINCE=CA
ORG_LOCATION=Oakland
ORG_NAME="your org"
ENVIRONMENT
S3_BUCKET_NAME
```

* After provisioning with openvpn, do not forget to copy your client1.ovpn file to your local box and download [tunnelblik](https://tunnelblick.net/downloads.html)
```
scp -i ~/.ssh/production-vpc-us-east-1.pem ubuntu@<your ip address for new openvpn server>:~/client-configs/files/client1.ovpn .
```

## kube-master:
* This stands up a kubernetes master instance utilizing kubeadm.
* This is meant to be run with packer, but can be run using `run.sh` as the above example:
```
./run.sh ~/.ssh/production-vpc-us-east-1.pem kube-master kube-master-test true
```

* This play is used in conjunction with packer to create a kube master via `kubeadm init`, and join slaves via `kubeadm join`.
* Join commands for kubeadm can be found on the kube-master instance you provision in the */tmp/kubey-join-cmd* file that is created.  This file has the base command that is needed by slaves to join, however, the default init token should provided not be used...
* _Note_ - the following requires you have the root ssh key you provisioned the instance with in the `./run.sh` script.
  - In the kube-master.yml playbook's kube-init.sh a non-expiring token is created [here](https://github.com/srflaxu40/ansible-m31/blob/master/roles/kube-master/templates/kube-init.sh#L14).  *This* is the token that should be used in the join command for slaves.
    - This can be found in the file  */tmp/kube-forever-token*.
* For [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) users, the cluster configuraton can be found in the `/etc/kubernetes/admin.conf` file.
  - This is also set to a configmap in the kube-master playbook that is set when the task runs.  You can get it by:
    `kubectl get configmaps kube-admin-<environment>`
* The discovery token `--discovery-token-ca-cert-hash` used in the slave kubeadm join command (see *kube-slave* playbook) can be created by running the following on your kubernetes master node:
```
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
```

- *Packer* - Currently the master does not work because it cannot dynamically generate new tokens / certs / keys on boot.  Stand up the master using ansible (outlined above), and then upload those tokens to your respective s3 buckets with the following format:

```
aws s3 cp <file> s3://{{s3_bucket_name}}/kube-forever-token-{{kube_master_tag}}-{{kubernetes_environment}}.txt

aws s3 cp <file> s3://{{s3_bucket_name}}/kube-sha256-token-{{kube_master_tag}}-{{kubernetes_environment}}.txt
```
- The above is the path/format the kube-slave ansible playbook expects the join token and sha256 hash to be in; see below for more instructions...

## kube-slave:
* See *kube-master* above for instructions on populating the init token / discovery token ca cert hash.
* The variables you need to set in `ansible_env` are:
```
S3_BUCKET_NAME
KUBE_MASTER_IP
KUBE_MASTER_TAG
ENVIRONMENT
```
  - Note that KUBE_MASTER_IP comes directly from the private IP of the instance you provisioned for kube-master.
  - KUBE_MASTER_TAG is the prettified tag name in ansible format (hyphens are changed to underscores); kube-master in the kube-master playbook becomes *kube_master* in the kube-slave playbook.  This is because ansible does not support hyphens in the tag names / environment.
  - ENVIRONMENT is arbitrary but required to tag the instances.
* Using the above information, the kube-slave playbook provisions instances and joins them to the kube master based on KUBE_MASTER_IP.  Tokens are taken from S3, which is why the KUBE_MASTER_TAG name is required as it is to arbitrary per user.

- *Packer* - Packer will pack a kubernetes slave - be sure to update the following environment variables in `ansible_env`:

```
KUBE_MASTER_TAG
KUBE_MASTER_IP
```


---

## Testing your roles with ansible-kitchen (in alpha)

### kitchen setup - (skip if you don't care for kitchen) rbenv instructions (v2.3.2) -
* Installing... [rbenv](https://jasoncharnes.com/install-ruby/), and upgrade your ruby to v2.3.2.v
```
brew install rbenv
rbenv init; # Paste output into your ~/.bash_profile
rbenv install 2.3.2
```

* Now install your gems
```
rbenv exec gem install bundler
rbenv exec bundle install
rbenv exec kitchen -h
```

* Update the `ansible_env` file to your respective environment variables for your AWS account before attempting test kitchen.
  Don't forget to source it:
`source ansible_env`

* This will run ${ROLE} in your ${ROLE}.yml file specified in ${HOSTFILE}.  This is great for just testing out configuration changes
  against a lightweight runtime container.  *Packer* does the actual packing into AMIs.
  * These variables are used in the `.kitchen.yml` file under the top-most parent directory of this repository.

```
rbenv exec kitchen converge
```
