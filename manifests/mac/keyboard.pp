# keyboard.pp - 2014-02-26 16:18
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::mac::keyboard {

  if $::manufacturer == 'Apple Inc.' {
    file { '/usr/lib/systemd/system/mac-keyboard.service' :
      ensure => 'file',
      source => 'puppet:///modules/master/mac-keyboard.service',
      mode   => '0444',
    }
    ->
    service { 'mac-keyboard' :
      ensure => 'running',
      enable => true,
    }
  }
}
