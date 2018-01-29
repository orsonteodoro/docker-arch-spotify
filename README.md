# docker-arch-spotify

This is a container containing Spotify.  It works with ALSA but can be configured or altered for PulseAudio.

Getting the container to get the soundcard(s) detected takes some work but at least it works.  What I would like to see is passwordless su so we can just go straight to Spotify, but it's kind of complicated.  It is not seamless because of the su password check restrictions.

It should work with hardened kernels with grsecurity.

Since it uses ALSA, you may only be able to use it in the container once your host releases the sound card.

It was tested on a host with Alpine Linux.

1. `git clone https://github.com/orsonteodoro/docker-arch-spotify.git`
2. `cd docker-arch-spotify`
3. `chmod +x compile.sh`
4. `./compile.sh`
5. `chmod +x run.sh`
6. `./run.sh`

The following steps are required for the sound card to be detected:

7. `sudo passwd`
8. `su`
9. `su spotify`
10. `aplay -l` (should detect the sound card devices)
11. `spotify`

(If you want PulseAudio, you need to do a `pulseaudio -D --exit-idle-time=-1` inside the container)

12.  If you use Facebook, you can use your Facebook user name and password to logon.

### License

The files in this repository alone are licensed under MIT.

Trademarks and copyrights referenced belong to their respective owners.

Software pulled by this container are not in the scope of this license.
