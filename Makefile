
REPO ?= srflaxu40

build:
	docker build --no-cache \
	-t $(REPO)/ansible:ubuntu-16.04 .

push:
	docker push $(REPO)/ansible:ubuntu-16.04
