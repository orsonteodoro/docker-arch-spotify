#!/bin/sh
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

if [ -n "$USE_CONTAINER_PULSEAUDIO" ]; then
	sudo groupmod --gid $AUDIO_GID audio
fi

#it gets quirky here
#the block below doesn't work in Dockerfile but here

sudo dbus-uuidgen --ensure=/etc/machine-id
sudo mkdir /run/dbus
sudo dbus-daemon --system

sudo aplay -l
out=$(sudo aplay -l)
echo $out | grep "no soundcards found..."
if [ "$?" -ne "0" ]; then
	echo "failure detecting cards.  send a github issue (bug report) on the project page to fix this."
	return 1
fi

#uncomment it if you don't have pulseaudio
#this only works if you can see the sound card list with aplay -l
if [ -n "$USE_CONTAINER_PULSEAUDIO" ]; then
	if [ -n "$ALSA_CARD" ] ; then
		sudo sed -i -e "s|#load-module module-alsa-sink|load-module module-alsa-sink device=$ALSA_CARD|g" /etc/pulse/default.pa || return 1
	else
		sudo sed -i -e "s|#load-module module-alsa-sink|load-module module-alsa-sink device=hw0,0|g" /etc/pulse/default.pa || return 1
	fi

	sudo -u spotify pulseaudio -D --exit-idle-time=-1 -v || return 1
fi

PULSE_SERVER="unix:/run/user/1000/pulse/native" sudo spotify
