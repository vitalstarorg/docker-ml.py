# Running X11 apps from Docker on MacOS or Linux
This is more for running X11 apps from Docker Desktop on MacOS host than Linux host since running docker on Linux has more ways to share X11 directly. Because sharing X11 on MacOS using Docker Desktop is limited, the only way I could find is using X11 Forwarding through ssh. So this docker image built on 20.04 LTS (Focal Fossa) with sshd.

This image also contains Python3 and libraries for machine learning with matplotlib.

# Build the Image
```bash
git clone git@github.com:vitalstarorg/docker-python3-X11.git
cd docker-python3-X11
docker build -t pythonx11 .
docker run -dit -p 26:22 --name pythonx11 pythonx11
```

# Run Python Apps
```bash
# Host: using XQuartz on Mac
xhost +

# Enter docker using ssh with X11 Forwarding, password: ml
ssh -X -p 26 ml@localhost

# Test X11
xclock

# Test App
./sample1.py
```
