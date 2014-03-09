# desktop.pp - 2014-02-15 04:48
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::desktop {
  
  if $::operatingsystem == 'Fedora' {

    package { [ 'xorg-x11-server-Xorg',
                'xorg-x11-drivers',
                'xorg-x11-xinit',
                'xorg-x11-fonts-75dpi',
                'xorg-x11-fonts-100dpi',
                'xorg-x11-fonts-ISO8859-14-75dpi',
                'xorg-x11-fonts-ISO8859-14-100dpi',
                'xorg-x11-fonts-misc',
                'xorg-x11-fonts-ISO8859-1-100dpi',
	        'xorg-x11-fonts-ISO8859-1-75dpi',
	        'xorg-x11-fonts-ISO8859-15-100dpi',
	        'xorg-x11-fonts-ISO8859-15-75dpi',
	        'xorg-x11-fonts-ISO8859-2-100dpi',
	        'xorg-x11-fonts-ISO8859-2-75dpi',
	        'xorg-x11-fonts-ISO8859-9-100dpi',
	        'xorg-x11-fonts-ISO8859-9-75dpi',
                'xorg-x11-twm',
                'xorg-x11-utils',
                'xorg-x11-util-macros',
                'xorg-x11-apps',
                'xorg-x11-docs',
                'xorg-x11-resutils',
                'xorg-x11-xbitmaps',
                'xorg-x11-xkb-extras',
                'xscreensaver-base',
                'dbus-x11',
                'dbus-tools',
                'alsa-utils',
                'alsa-tools',
                'alsa-plugins-pulseaudio',
                'fvwm',
                'firefox',
                'keepassx',
                'pulseaudio',
                'pulseaudio-utils',
                #'vlc',
              ] :
      ensure => 'installed',
    }
    exec { 'open xserver port' :
      command => '/bin/firewall-cmd --permanent --zone=public --add-port=6000/tcp'
    }
    # Adobe Flash
    file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux' :
        source => 'puppet:///modules/master/RPM-GPG-KEY-adobe-linux',
    }->
    yumrepo { 'adobe-linux-x86_64' :
      name        => 'adobe-linux-x86_64',
      descr       => 'Adobe Systems Incorporated',
      baseurl     => 'http://linuxdownload.adobe.com/linux/x86_64/',
      enabled     => 1,
      gpgcheck    => 1,
      gpgkey      => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux',
    }->
    package { 'flash-plugin' :
      ensure => 'installed',
    }
  }
}
