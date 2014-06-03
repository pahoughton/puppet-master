# master-media_spec.rb - 2014-06-03 02:28
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# master-desktop_spec.rb - 2014-03-09 09:33
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

$pkgs = [
    'alsa-plugins-pulseaudio',
    'alsa-tools',
    'alsa-utils',
    'pulseaudio',
    'pulseaudio-utils',
               ]

# Only Fedora currently supported.
['Fedora'].each { |os|
  describe 'master::media', :type => :class do
    let(:facts) do {
        :osfamily  => 'redhat',
        :operatingsystem => os,
    } end
    context "supports operating system: #{os}" do
      context "provides master::desktop class which" do
        it { should contain_class('master::media') }
        $pkgs.each{|pkg|
          it { should contain_package(pkg) }
        }
      end
    end
  end
}
