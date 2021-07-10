#!/bin/bash
docker build -t pythonx11 --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" .
