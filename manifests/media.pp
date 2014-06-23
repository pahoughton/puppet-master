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
            #'pithos',
            'vlc',
            'sox',
            #'google-chrome',
            ]

  # fixme - downloaded - need link for hal-flash-0.2.0rc1-1.fc20.x86_64.rpm
  $ofpkgs = $::osfamily  ? {
    'Fedora' => [ 'hal-flash',
                  ],
    default  => [],
  }

  ensure_packages($pkgs)
  ensure_packages($ofpkgs)

}
