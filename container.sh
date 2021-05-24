#!/bin/bash

# argument processing
params=()
while (( "$#" )); do
  case "$1" in
    -p|--path)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        _path=$2; shift 2; else
        echo "Error: -p path" >&2; exit 1; fi;;
    -t|--port)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        _port=$2; shift 2; else
        echo "Error: -t port" >&2; exit 1; fi;;
    -s|--stop) _stop=1; shift 1;;
    -r|--restart) _restart=1; shift 1;;
    -k|--kill) _kill=1; shift 1;;

    -h|--help) _help=1; shift 1;;
    -v|--verbose) _verbose=1; shift 1;;
    --) shift; break;;
    -*|--*=) echo "Error: unknown option $1" >&2; exit 1;;
    *) params+=("$1"); shift;;
  esac
done
eval set -- "${params[@]}"
if [ ! -z "$_verbose" ]; then set -x; fi

# Checking running container
docker container inspect ml > /dev/null 2>&1
running="$?"

if [ "$running" == "1" ]; then
  message="container is stopped"
else
  message="container is running"
fi

if [ ! -z "$_stop" ]; then
  if [ "$running" == "0" ]; then
    docker stop ml
  fi
  exit
fi

if [ ! -z "$_restart" ]; then
  if [ "$running" == "0" ]; then
    docker stop ml
  fi
  docker start ml
  exit
fi

if [ ! -z "$_kill" ]; then
  if [ "$running" == "0" ]; then
    docker stop ml
  fi
  docker rm -v ml
  exit
fi

if [ -z "$_port" ]; then
  _port=26 # default ssh port used
fi

if [ -z "$_help" ]; then
  # If not running, start a container
  if [ "$running" == "1" ]; then
    if [ ! -z "$_path" ]; then
      docker run -dit -p $_port:22 -v $_path:/home/ml/current --name ml pythonx11 
    else
      docker run -dit -p $_port:22 -v $(pwd):/home/ml/current --name ml pythonx11
    fi
    sleep 1
  fi
  ssh -ACXq -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" -p $_port ml@localhost
  exit
fi
# help message go here
echo "Usage: $(basename $0)
  ssh into the container. Start the container if needed: ${message}

  -p --path:    Mount the path to ~/current inside container. Default is current path.
  -t --port:    Port we use for the SSH port.
  -s --stop:    Stop the container.
  -r --restart: Stop and start the container.
  -k --kill:    Stop and remove the container.

  -h --help  
  -v --verbose: Verbose
"

