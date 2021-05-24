FROM ubuntu:focal

ARG ssh_pub_key

ENV LANG=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV REMOVE_DASH_LINECOMMENT="true"
ENV SHELL /bin/bash
ENV UID 1000
ENV USER ml
ENV HOME /home/$USER

RUN useradd -rm -d $HOME -s /bin/bash -g root -G sudo -u $UID $USER
RUN echo "$USER:$USER" | chpasswd
RUN usermod -aG sudo $USER

WORKDIR $HOME

# ~/.ssh make ssh password-less
RUN mkdir -p $HOME/.ssh && \
    chmod 0700 $HOME/.ssh && \
    echo "$ssh_pub_key" > $HOME/.ssh/authorized_keys && \
    chmod 600 $HOME/.ssh/authorized_keys && \
    chown -R $USER:root $HOME/.ssh

# copy resource files
ADD bin ./bin
RUN chmod -R +x bin/*
RUN chown -R $USER:root $HOME/bin

# X11 & OpenSSH & Basic Tools
RUN apt-get -y update \
    && apt-get -y --no-install-recommends install \
    xorg openssh-server sudo wget vim tmux htop
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
COPY requirements*.txt ./
RUN for i in requirements*.txt; do pip3 install --no-cache-dir -r $i; done
RUN rm requirements*.txt

# clean
RUN apt-get autoremove -y && apt-get clean && \
    rm -rf /usr/local/src/*

# copy config files
ADD config ./config
RUN chown -R $USER:root $HOME/config
RUN mv $HOME/config/.vimrc ~/.vimrc
RUN mv $HOME/config/.vim ~/.vim
RUN mv $HOME/config/.tmux.conf ~/.tmux.conf
RUN /usr/bin/vim -es -u ./config/setup-vimrc -i NONE -c "PlugInstall" -c "qa"

RUN service ssh start
EXPOSE 22

USER $USER

ENTRYPOINT ["./bin/startup.sh"]
CMD ["/bin/sh"]
