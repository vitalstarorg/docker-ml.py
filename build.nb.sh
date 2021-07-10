#!/bin/bash
#DOCKER_BUILDKIT=0
#docker build -t nbx11 --progress=plain --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" --file Dockerfile.nb .
docker build -t nbx11 --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" --file Dockerfile.nb .
