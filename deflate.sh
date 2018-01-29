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

echo "Removing cruft here and security hazards"

sudo pacman --noconfirm -R git

echo "Removing inetutils (containing telnet)"
sudo pacman --noconfirm -R inetutils
#sudo rm $(pacman -Ql inetutils) 2&>1 > /dev/null || true

echo "Removing mount and other utils"
sudo rm $(pacman -Ql util-linux) 2&>1 > /dev/null || true

echo "Removing compiler essentials"
sudo rm /usr/bin/curl
#sudo rm /usr/bin/wget
sudo rm /usr/bin/gcc
sudo rm /usr/bin/g++
#sudo rm /usr/bin/clang
#sudo rm /usr/bin/clang++
sudo rm /usr/sbin/perl
sudo rm /usr/sbin/as

echo "Removing web utilities"
#sudo rm /usr/bin/curl
#sudo rm /usr/bin/wget

echo "Removing shadow"
sudo rm $(pacman -Ql shadow) 2&>1 > /dev/null || true

echo "Removing coreutils and other utilities"
sudo rm $(pacman -Ql coreutils | grep -v "rm" | grep -v "echo") 2&>1 /dev/null || true

echo "Removing pacman"
sudo rm $(pacman -Ql pacman) 2&>1 > /dev/null || true

echo "Removing rm"
sudo echo "" > /bin/rm

