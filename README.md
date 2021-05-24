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

# Start the container and/or ssh into it with X11 Forwarding, password: ml
./container.sh 

# Test X11
xclock

# Test App
./sample1.py
```
