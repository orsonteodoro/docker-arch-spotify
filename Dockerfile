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

FROM base/archlinux

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

WORKDIR /home/spotify/aur
RUN git clone https://aur.archlinux.org/spotify.git
WORKDIR /home/spotify/aur/spotify
RUN sudo -u spotify makepkg --noconfirm -si

WORKDIR /home/spotify/aur/
RUN git clone https://aur.archlinux.org/paxctl.git
WORKDIR /home/spotify/aur/paxctl
RUN sudo -u spotify makepkg --noconfirm -si

#for grsecurity kernels like Alpine and Hardened Gentoo
RUN sudo paxctl -C /usr/share/spotify/spotify
RUN sudo paxctl -z /usr/share/spotify/spotify
RUN sudo paxctl -m /usr/share/spotify/spotify

RUN sudo pacman --noconfirm -S pulseaudio
RUN sudo pacman --noconfirm -S pulseaudio-alsa
RUN sudo pacman --noconfirm -S alsa-lib

RUN sudo pacman --noconfirm -S alsa-utils

ADD debug-tools.sh /usr/bin/debug-tools.sh
RUN sudo chmod +x /usr/bin/debug-tools.sh
ARG debug
RUN sudo /usr/bin/debug-tools.sh $debug

RUN sudo sed -i -e 's|#load-module module-native-protocol-unix|load-module module-native-protocol-unix|g' /etc/pulse/default.pa || return 1
RUN sudo sed -i -e 's|#load-module module-alsa-sink|load-module module-alsa-sink device=dmix|g' /etc/pulse/default.pa || return 1
USER root
RUN echo -e ".ifexists module-x11-publish.so\nload-module module-x11-publish\n.endif\n" >> /etc/pulse/default.pa || return 1
USER spotify

ADD start-spotify.sh /usr/bin/start-spotify.sh
RUN sudo chmod +x /usr/bin/start-spotify.sh

#quirky
USER root
ADD start-dbus.sh /usr/bin/start-dbus.sh
RUN sudo chmod +x /usr/bin/start-dbus.sh
RUN /usr/bin/start-dbus.sh
USER spotify

#harden environment... make it static
ADD deflate.sh /usr/bin/deflate.sh
RUN sudo chmod +x /usr/bin/deflate.sh
RUN sudo /usr/bin/deflate.sh

#aplay -l can detect sound cards on root or su from root
USER root

WORKDIR /home/spotify

ENTRYPOINT "/usr/bin/start-spotify.sh"
