#!/bin/bash
docker container inspect ml > /dev/null 2>&1
if [ "$?" == "0" ]; then
  docker stop ml
  docker rm -v ml
fi
docker build -t pythonx11 --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" .
