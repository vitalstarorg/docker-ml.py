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
    -i|--image)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        _image=$2; shift 2; else
        echo "Error: -i image" >&2; exit 1; fi;;
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
container=$1
if [ ! -z "$container" ]; then
  # Checking running container
  state=$(docker container inspect --format='{{json .State.Running}}' $container  2>&1)
  running=$? # 0 started 1 not running 2 stopped
  if [ "$running" == "0" ]; then
    if [ "$state" == "true" ]; then
      message="container is running"
    else
      message="container is stopped"
      running=2
    fi
  else
    message="container is not running"
  fi
else
  message="found no container_id"
  _help=1
fi

printf "Info: %s\n" "$message"

if [ ! -z "$_stop" ]; then
  if [ "$running" == "0" ]; then
    docker stop $container
  fi
  exit
fi

if [ ! -z "$_restart" ]; then
  if [ "$running" == "0" ]; then
    docker stop $container
  fi
  docker start $container
  exit
fi

if [ ! -z "$_kill" ]; then
  if [ "$running" == "0" ]; then
    docker stop $container
  fi
  docker rm -v $container
  exit
fi

if [ -z "$_port" ]; then
  _port=26 # default ssh port used
fi

if [ -z "$_help" ]; then
  # If not running, start a container
  if [ "$running" == "1" ]; then
    if [ -z "$_image" ]; then
      message="--image option is needed to start a container."
      _help=1
    else
      if [ ! -z "$_path" ]; then
        docker run -dit -p $_port:22 -v $_path:/home/ml/current --name $container $_image
      else
        docker run -dit -p $_port:22 -v $(pwd):/home/ml/current --name $container $_image
      fi
      sleep 1
    fi
  else
    if [ "$running" == "2" ]; then
      docker start $container
    fi
    sleep 1
  fi
  if [ -z "$_help" ]; then
    ssh -X -q -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" -L 0.0.0.0:8501:0.0.0.0:8501 -L 0.0.0.0:8888:0.0.0.0:8888 -p $_port -t ml@localhost 'cd ~/current; bash'
    exit
  fi
fi
# help message go here
echo "Usage: $(basename $0) [option] container_id
  start, stop & ssh into the container

  -p --path:    Mount the path to ~/current inside container. Default is current path.
  -t --port:    Port we use for the SSH port.
  -i --image:   Docker image.
  -s --stop:    Stop the container.
  -r --restart: Stop and start the container.
  -k --kill:    Stop and remove the container.

  -h --help  
  -v --verbose: Verbose

  MSG: ${message}
"

