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

sudo groupmod --gid $AUDIO_GID audio

#it gets quirky here
#the block below doesn't work in Dockerfile but here
sudo dbus-uuidgen --ensure=/etc/machine-id || return 1
sudo mkdir /run/dbus || return 1
sudo dbus-daemon --system || return 1

out=$(aplay -l)
echo $out | grep "no soundcards found..."
if [ "$?" -eq "0" ]; then
	echo "failure detecting cards.  send a github issue (bug report) on the project page to fix this."
	return 1
fi

echo "detecting sound cards"
aplay -l

echo "To fix the sound card detection you need to"
echo "1. set any root password: sudo passwd"
echo "2. logon root with that password: su"
echo "3. logon spotify unix account: su spotify"
echo "4. verify that sound detection works: aplay -l"
echo "You will be placed in interactive mode."

#uncomment it if you don't have pulseaudio
#this only works if you can see the sound card list with aplay -l
if [ -n "USE_CONTAINER_PULSEAUDIO" ]; then
	pulseaudio -D --exit-idle-time=-1 -v || return 1
fi

#PULSE_SERVER="unix:/run/user/1000/pulse/native" spotify --ui.hardware_acceleration=false
bash -i
