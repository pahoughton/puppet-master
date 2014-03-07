# libvirt.pp 2014-02-15 05:03
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::libvirt { 
  if $::operatingsystem == 'Fedora' { 
    package { [ 'libguestfs',
                'libguestfs-tools',
                'libguestfs-tools-c',
              ] :
      ensure => 'installed',
    }
  }
  policykit::localauthority { 'paul virt management':
    identity        => "unix-user:paul",
    action          => 'org.libvirt.unix.manage',
    result_active   => 'yes',
    result_any      => 'yes',
    result_inactive => 'yes',
  }
}
