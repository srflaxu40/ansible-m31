# ansible-m31

Run, pack, and provision your infrastructure with Ansible code against Amazon's Cloud (AWS).
Test your code on-the-fly with ansible-kitchen, and docker for mac.


# Development Setup

* This repo expects you've installed [Homebrew](https://brew.sh/).
* Install rbenv with the instructions below.
* This repo expects that you have installed [Docker for Mac](https://docs.docker.com/docker-for-mac/install/).
* Please also setup your [aws configuration](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).


## rbenv instructions (v2.3.2)
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

* You should now be in the ansible project with your pip modules installed.

## Roles:

## OpenVPN

* This does not create your VPC for you.
* This does not create any subnets, but it assumes the subnet you specify in `ansible_env` prior to source'ing it
  has a route table that connects it to your VPC's internet gateway.
* Important - this has only been tested on the base Ubuntu AMI for 16.04 in us-east-1 (ami-cd0f5cb6).  Running it on
  other AMIs may require modifications / forking this repository.
* This supports only the AWS cloud.
* Example Route Table for a Public Subnet:
![Alt text](/images/public_subnet.png?raw=true "Example Route Table.")

* Example Security Group that gives access to 443 for VPN access, ssh access to the VPN, and also allows traffic to it from an internal security group:
![Alt text](/images/vpn_sg.png?raw=true "Example VPN Security Group.")

* openvpn - This requires running the openvpn.sh script _after_ setting your vars in `ansible_env`.
  - Please note that this spins up an ec2 instance first, and then provisions it with the openvpn play/role.
  - The reason for this is to avoid any weirdness having to get new IPs alongside packer, etc, when an instance
    exists behind a launch config; openvpn configurations for clients / server require static IPs.
  - Please set your AWS keys in your credentials keychain as noted above in Development Setup.
  - Also, please update `ansible_env` to values specific to your VPC, Subnet (must be public for a VPN), Security Groups,
    IAM Role, etc...
  - USAGE:
```
./openvpn.sh <path to your key for this server>

```

## Afterward, copy your client1.ovpn file to your local box and download [tunnelblik](https://tunnelblick.net/downloads.html)
```
scp -i ~/.ssh/production-vpc-us-east-1.pem ubuntu@10.1.2.212:~/client-configs/files/client1.ovpn .
```

* kubernetes - This is meant to be run with packer.  Packer templates are under the `./packer` directory.
  - This play is used in conjunction with packer to create a kube master via `kubeadm init`, and join slaves via `kubeadm join`.

---

## Testing your roles with ansible-kitchen (in alpha)

* Update the `ansible_env` file to your respective environment variables for your AWS account before attempting test kitchen.
  Don't forget to source it:
`source ansible_env`

* This will run ${ROLE} in your ${ROLE}.yml file specified in ${HOSTFILE}.  This is great for just testing out configuration changes
  against a lightweight runtime container.  *Packer* does the actual packing into AMIs.
  * These variables are used in the `.kitchen.yml` file under the top-most parent directory of this repository.

```
rbenv exec kitchen converge
```
