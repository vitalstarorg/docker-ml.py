FROM ubuntu:focal

ENV REMOVE_DASH_LINECOMMENT="true"
ENV SHELL /bin/bash
ENV UID 1000
ENV USER ml
ENV HOME /home/$USER

RUN useradd -rm -d $HOME -s /bin/bash -g root -G sudo -u $UID $USER
RUN echo "$USER:$USER" | chpasswd
RUN usermod -aG sudo $USER

WORKDIR $HOME

# X11 & OpenSSH
RUN apt-get -y update \
    && apt-get -y --no-install-recommends install \
    xorg openssh-server sudo vim
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
  # sudoer doesn't need password
RUN echo "X11UseLocalHost no" >> /etc/ssh/sshd_config
  # Need this for X11 Forwarding to work

# Networking Tools for diagnostic
#RUN apt-get -y update \
#    && apt-get -y --no-install-recommends install \
#    net-tools iputils-ping traceroute curl

# Build Tools
RUN apt-get -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libatlas-base-dev gfortran cmake build-essential git tk \
    && apt-get update \
    && apt-get clean \
    && apt-get autoremove -y

# Python3.9 Basic
RUN apt-get -y --no-install-recommends install \
    python3.9 python3-pip python3-tk

# Python Libraries
COPY requirements.txt ./requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# clean
RUN apt-get autoremove -y && apt-get clean && \
    rm -rf /usr/local/src/*

# copy resource files
COPY startup.sh ./startup.sh
RUN chmod +x ./startup.sh
RUN service ssh start

ENV LANG=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8

EXPOSE 22

USER $USER

ENTRYPOINT ["./startup.sh"]
CMD ["/bin/sh"]
