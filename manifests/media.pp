# media.pp - 2014-06-03 02:24
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::media {

  $pkgs = [ 'alsa-plugins-pulseaudio',
            'alsa-tools',
            'alsa-utils',
            'pulseaudio',
            'pulseaudio-utils',
            ]
  ensure_packages($pkgs)
}
