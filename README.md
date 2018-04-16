# ansible-m31

Run, and provision against Amazon's Cloud (AWS).

### TABLE OF CONTENTS

   * [ansible-m31](#ansible-m31)
   * [Development Setup](#development-setup)
      * [Setting up your local virtualenv](#setting-up-your-local-virtualenv)
      * [Roles:](#roles)
         * [Really Important (ansible_env):](#really-important-ansible_env)
   * [OpenVPN:](#openvpn)
   * [Windows:](#windows)


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
pip install requirements.txt
```

## Roles:

* No network arch. (VPCs, subnets, etc) are created by these playbooks.  These playbooks expect you have a VPC created with existing subnets.  In order for certain roles to work (like openvpn), you must have a public subnet connected to your internet gateway (IGW) via a route table.  This is necessary for instances created by the ec2.yml playbook that require a public subnet; a public subnet infers instances will have public IPs and direct access to your VPC's Internet Gateway (IGW).

### Really Important (ansible_env):
* The _*ansible_env*_ file sets environment variables that are required to be changed; this is super important for you to customize to your own values.  Others that exist, but do not have to be changed (defaults) are inside the standard vars directory for a role `roles/<role name>/vars/main.yml`.
  - These vars can also be overridden on the command line or inside the run.sh script by adding the `--extra-args` argument.
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

  ./run.sh \$PRIVATE_KEY_PATH \$ROLE \$TAG_NAME \$BOOL
 
  \$PRIVATE_KEY_PATH - the path to your private key PEM file downloades when you created an IAM key in AWS.
  \$ROLE - the role (play) you wish to run; under ./roles/
  \$TAG_NAME - the name you wish to tag your instance with; this will automatically prefix the ENVIRONMENT
    variable set in the ansible_env file.
  \$ENVIRONMENT - the environment; this gets joined with tag name for dynamic inventory.
  \$BOOL - Spin up a new EC2 instance or provision the old one using ansible AWS EC2 tagging in your playbook.

EXAMPLE:

  ./run.sh ~/.ssh/production-vpc-us-east-1.pem openvpn openvpn development true
```

* Please note that specifying *false* as the BOOL argument expects that an instance exists with the tag name and environment variable (inside ansible_env).  This then provisions that instance with the plays designated by ROLE.
* Here is an example of how ansible uses the tag name and environment along with dynamic inventory to provision the instance:
```
---
# file: openvpn.yml
- name: Configure and deploy openvpn
  hosts: tag_Name_{{ tag_name }}_{{ tag_environment }}
  remote_user: ubuntu
  become: yes 
  gather_facts: False
  roles:
    - python
    - hosts
    - openvpn
```

# OpenVPN:
* Before running the openvpn provisioning, be sure that you set the following environment variables:
```
SG_ID
SUBNET_ID (must be a public subnet with Internet Gateway Access)
AMI_ID
IAM_ROLE
SSH_KEY (the name of the key without the .PEM extension in EC2->Keys)
REGION
ORG_COUNTRY=US
ORG_PROVINCE=CA
ORG_LOCATION=Oakland
ORG_NAME="your org"
```

* Now source the file:
`source ansible_env`

* Now create the ec2 instance and provision it:
`./run.sh ~/.ssh/<your ec2 key >.pem openvpn openvpn true`

* After provisioning with openvpn, do not forget to copy your client1.ovpn file to your local box and download [tunnelblik](https://tunnelblick.net/downloads.html)
```
scp -i ~/.ssh/<your ec2 key >.pem ubuntu@<your ip address for new openvpn server>:~/client-configs/files/client1.ovpn .
```

* Add this to tunnelblik, and connect to interact with your VPC.


# Windows:
* This requres you install the pywinrm module in requirements.txt
* For windows machines you need to follow the directions outlined in docs/WINDOWS-README.md in order to setup WinRM as a service, and enable basic auth.
* The window-hosts file outlines hosts in order to provision.
* You must ensure ansible fact gathering is enabled (in windows-hosts).
* The following roles support windows provisioning:
  - Jenkins
* Example of provisioning a remote Windows server over WinRM; notice we set our basic auth password for our windows user on the CML; Other auth mechanisms such as Kerberos, AD exist:
```
ansible-playbook -i windows-hosts -e "target=jknepper ansible_password=asdfio12!@" jenkins-master.yml --tags="master" -vvv
```
