#!/usr/bin/env bash
# Install packages from Debian/Ubuntu repositories

POKY_REQUIREMENTS="gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev xterm"
PACKAGES_I_LIKE_TO_HAVE="git tig tree htop dos2unix ack-grep"

export DEBIAN_FRONTEND=noninteractive

apt-get -y update
#apt-get -y upgrade
apt-get -y install $POKY_REQUIREMENTS $PACKAGES_I_LIKE_TO_HAVE
apt-get -y autoremove --purge
