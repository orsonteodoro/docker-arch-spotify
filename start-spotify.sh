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

aplay -l
out=$(aplay -l)
echo $out | grep "no soundcards found..."
if [ "$?" -eq "0" ]; then
	echo "failure detecting cards.  send a github issue (bug report) on the project page to fix this."
	exit 1
fi

#uncomment it if you don't have pulseaudio
#this only works if you can see the sound card list with aplay -l
if [ -n "USE_CONTAINER_PULSEAUDIO" ]; then
	pulseaudio -D --exit-idle-time=-1 -v || return 1
fi

# there is a black screen problem confirmed
# see https://community.spotify.com/t5/Desktop-Windows/Spotify-Black-screen/td-p/738117 for black screen
# see https://community.spotify.com/t5/Desktop-Mac-old/Spotify-on-MAC-blocked-while-opening/td-p/1477123/page/2

#PULSE_SERVER="unix:/run/user/1000/pulse/native" spotify --disable-accelerated-layers --disable-accelerated-fixed-root-background
bash -i
