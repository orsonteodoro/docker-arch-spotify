# Copyright (c) 2018 Orson Teodoro
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

FROM archlinux/archlinux:base

MAINTAINER Orson Teodoro <orsonteodoro@hotmail.com>

RUN pacman --noconfirm -Syu

RUN pacman --noconfirm -S base-devel
RUN pacman --noconfirm -S xorg-server
RUN pacman --noconfirm -S shadow
RUN pacman --noconfirm -S sudo
RUN pacman --noconfirm -S git

RUN chmod 0660 /etc/sudoers
RUN sed -i -e 's|# %wheel ALL=(ALL) NOPASSWD: ALL|%wheel ALL=(ALL) NOPASSWD: ALL\nspotify ALL=(ALL:ALL) NOPASSWD:ALL\n|g' /etc/sudoers || return 1
RUN chmod 0440 /etc/sudoers

RUN echo "Creating user spotify"
RUN useradd -m spotify
RUN echo "Deleting password for spotify"
RUN passwd -d spotify

RUN gpasswd -a spotify users
RUN gpasswd -a spotify audio
RUN gpasswd -a spotify video
RUN gpasswd -a spotify wheel

USER spotify

WORKDIR /home/spotify
RUN mkdir aur
RUN cd aur

RUN gpg --keyserver keyserver.ubuntu.com --recv-keys FCF986EA15E6E293A5644F10B4322F04D67658D8
RUN curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | gpg --import -

WORKDIR /home/spotify/aur
RUN git clone https://aur.archlinux.org/yay.git
WORKDIR /home/spotify/aur/yay
RUN sudo -u spotify makepkg --noconfirm -si

RUN sudo -u spotify yay --noconfirm -Syyu
RUN sudo -u spotify yay -S --noconfirm paxctl
RUN sudo -u spotify yay -S --noconfirm spotify

RUN sudo pacman --noconfirm -S pulseaudio
RUN sudo pacman --noconfirm -S pulseaudio-alsa
RUN sudo pacman --noconfirm -S alsa-lib

RUN sudo pacman --noconfirm -S alsa-utils

# Optional dependencies for spotify
RUN sudo -u spotify yay --noconfirm -S ffmpeg-compat-57 # Adds support for playback of local files
RUN sudo -u spotify yay --noconfirm -S zenity # Adds support for importing local files
RUN sudo -u spotify yay --noconfirm -S libnotify # Desktop notifications

# For login prompt
RUN sudo pacman --noconfirm -S firefox

# For grsecurity kernels like Alpine and Hardened Gentoo
RUN sudo paxctl -C /opt/spotify/spotify
RUN sudo paxctl -z /opt/spotify/spotify
RUN sudo paxctl -m /opt/spotify/spotify

ADD debug-tools.sh /usr/bin/debug-tools.sh
RUN sudo chmod +x /usr/bin/debug-tools.sh
ARG debug
RUN sudo /usr/bin/debug-tools.sh $debug

RUN sudo sed -i -e 's|#load-module module-native-protocol-unix|load-module module-native-protocol-unix|g' /etc/pulse/default.pa || return 1
RUN sudo sed -i -e 's|load-module module-udev-detect|#load-module module-udev-detect|g' /etc/pulse/default.pa || return 1
USER root
RUN echo -e ".ifexists module-x11-publish.so\nload-module module-x11-publish\n.endif\n" >> /etc/pulse/default.pa || return 1
USER spotify

WORKDIR /home/spotify

ADD travisci-test.sh /usr/bin/travisci-test.sh
RUN sudo chmod +x /usr/bin/travisci-test.sh
ARG travisci
RUN sudo /usr/bin/travisci-test.sh $travisci

ADD start-spotify.sh /usr/bin/start-spotify.sh
RUN sudo chmod +x /usr/bin/start-spotify.sh

# Harden environment... make it static
ADD deflate.sh /usr/bin/deflate.sh
RUN sudo chmod +x /usr/bin/deflate.sh
#RUN sudo /usr/bin/deflate.sh

USER spotify

ENTRYPOINT "/usr/bin/start-spotify.sh"
