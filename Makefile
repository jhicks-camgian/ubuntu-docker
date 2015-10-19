#!/usr/bin/make
# USAGE: 'sudo make' to build a 'vivid' image (camgian/ubuntu:vivid).
# Define variables on the make command line to change behaviour
# e.g.
#       sudo make release=vivid arch=amd64 tag=vivid-amd64

# variables that can be overridden:
release ?= vivid
prefix  ?= camgian
arch    ?= amd64
mirror  ?= http://us.archive.ubuntu.com/ubuntu
tag     ?= $(release)-$(arch)

build: $(tag)/root.tar $(tag)/Dockerfile
	docker build -t $(prefix)/ubuntu:$(tag) $(tag)

rev=$(shell git rev-parse --verify HEAD)
$(tag)/Dockerfile: Dockerfile.in $(tag)
	sed 's/SUBSTITUTION_FAILED/$(rev)/' $< >$@

$(tag):
	mkdir $@

$(tag)/root.tar: roots/$(tag) $(tag)
	cd roots/$(tag) && tar cf ../../$(tag)/root.tar ./

roots/$(tag):
	mkdir -p $@ \
		&& debootstrap --arch $(arch) $(release) $@ $(mirror) \
		&& chroot $@ apt-get clean

clean:
	rm -f $(tag)/root.tar $(tag)/Dockerfile
	rm -r roots/$(tag)
	test -d $(tag) && rmdir $(tag)

.PHONY: clean build
