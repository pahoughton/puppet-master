# master-desktop_spec.rb - 2014-03-09 09:33
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

$pkgs = [
    'dbus-tools',
    'dbus-x11',
    'icedtea-web',
    'firefox',
    'flash-plugin',
    'fvwm',
    'jigdo',
    'keepassx',
    'xorg-x11-docs',
    'xorg-x11-drivers',
    'xorg-x11-fonts-100dpi',
    'xorg-x11-fonts-75dpi',
    'xorg-x11-fonts-ISO8859-1-100dpi',
    'xorg-x11-fonts-ISO8859-14-100dpi',
    'xorg-x11-fonts-ISO8859-14-75dpi',
    'xorg-x11-fonts-ISO8859-15-100dpi',
    'xorg-x11-fonts-ISO8859-15-75dpi',
    'xorg-x11-fonts-ISO8859-1-75dpi',
    'xorg-x11-fonts-ISO8859-2-100dpi',
    'xorg-x11-fonts-ISO8859-2-75dpi',
    'xorg-x11-fonts-ISO8859-9-100dpi',
    'xorg-x11-fonts-ISO8859-9-75dpi',
    'xorg-x11-fonts-misc',
    'xorg-x11-resutils',
    'xorg-x11-server-Xorg',
    'xorg-x11-twm',
    'xorg-x11-util-macros',
    'xorg-x11-utils',
    'xorg-x11-xbitmaps',
    'xorg-x11-xinit',
    'xorg-x11-xkb-extras',
    'xpdf',
    'xscreensaver-base',
               ]

# Only Fedora currently supported.
['Fedora'].each { |os|
  describe 'master::desktop', :type => :class do
    let(:facts) do {
        :osfamily  => 'redhat',
        :operatingsystem => os,
    } end
    context "supports operating system: #{os}" do
      context "provides master::desktop class which" do
        it { should contain_class('master::desktop') }
        $pkgs.each{ |pkg|
          it { should contain_package(pkg) }
        }
      end
      it "opens X11 port 6000" do
        if os == 'Fedora'
          should contain_exec('open X11 port')
        end
      end
    end
  end
}
