# ansible-m31

Run, pack, and utilize your ansible code against Amazon's Cloud (AWS).
Test your code on-the-fly with ansible-kitchen.


# Development Setup

* This repo expects you've installed [Homebrew](https://brew.sh/).
* Install rbenv with the instructions below.
* This repo expects that you ahve installed [Docker for Mac](https://docs.docker.com/docker-for-mac/install/).


## rbenv instructions
* Installing... [rbenv](https://jasoncharnes.com/install-ruby/), and upgrade your ruby version to >= v2.2.2
```
brew install rbenv
rbenv init; # Paste output into your ~/.bash_profile
rbenv install 2.3.2
rbenv local 2.3.2
```

* Now install your gems
```
rbenv exec gem install bundler
rbenv exec bundle install
rbenv exec kitchen -h
```

## Setting up your local virtualenv

1. Install virtualenv
  - `(sudo) pip install virtualenv`
2. Activate project
  - `source ./ansible/bin/activate`
3. Install bundler:
  - `(sudo) gem install bundler`
4. Install gems:
  - `(sudo) bundle install`

* You should now be in the ansible project with your pip modules installed.

## Testing your roles with ansible-kitchen

* Update the `ansible_env` file to your respective environment variables for your AWS account before attempting test kitchen.
  Don't forget to source it:
  `source ansible_env`

* This will run ${ROLE} in your ${ROLE}.yml file specified in ${HOSTFILE}.  This is great for just testing out configuration changes
  against a lightweight runtime container.  *Packer* does the actual packing into AMIs.
  * These variables are used in the `.kitchen.yml` file under the top-most parent directory of this repository.

```
rbenv exec kitchen converge
```
