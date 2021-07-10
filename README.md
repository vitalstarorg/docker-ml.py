# Running X11 apps from Docker on MacOS or Linux
This is more for running X11 apps from Docker Desktop on MacOS host than Linux host since running docker on Linux has more ways to share X11 directly. Because sharing X11 on MacOS using Docker Desktop is limited, the only way I could find is using X11 Forwarding through ssh. So this docker image built on 20.04 LTS (Focal Fossa) with sshd.

This image also contains Python3 and libraries for machine learning with matplotlib.

# Build the Image
```bash
git clone git@github.com:vitalstarorg/docker-python3-X11.git
cd docker-python3-X11
./build.sh  # build pythonx11 image with ~/.ssh/id_rsa.pub
```

# Run Python Apps
```bash
# Host: using XQuartz on Mac
xhost +

# Start the container and/or ssh into it with X11 Forwarding.
# If everything works, this should ssh into the container without
# asking for password as id_rsa.pub should be in authorized_keys.
# Your current folder will be mounted ~/current inside container
cd ~/app
./container.sh --image pythonx11 myapp

# After the container is started, simply use this to ssh into it.
./container.sh myapp

# container.sh has more functions to control the container and ssh.
# Simple testing can be done below for diagnostic purpose.
docker run -dit -p 26:22 --name myapp pythonx11
ssh -ACX -p 26 ml@localhost

# Test X11
xclock

# Test Python App
./sample1.py
```
# Run all-spark-notebook
This is now enhanced to run [all-spark-notebook](https://github.com/jupyter/docker-stacks/tree/master/all-spark-notebook) with X11 and ssh server together.
```bash
# Use this to build the notebooke & pythonx11 image instead
./build.nb.sh
./container.sh --image pythonx11 myapp
notebook.sh # start the notebook server. Stay login to  keep the tunnels.

# container.sh has the ssh tunnel for most used ports. Or do this and keep
# the terminal running.
docker exec -it --user ml myapp start-notebook.sh
```
