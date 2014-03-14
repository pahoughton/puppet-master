# user.pp 2014-02-15 09:13
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
define master::user (
  $uid     = undef,
  $comment = undef,
  $email   = undef,
  $group   = undef,
  $gid     = undef,
  $groups  = undef,
  $home    = undef,
  $pass    = undef,
  $rsa     = undef,
  $libvirt = undef,
  ) {
  
  $user    = $name
  
  $homedir = $home ? {
    undef   => "${master::homebase}/${user}",
    default => $home,
  }
  
  group { $group :
    ensure => 'present',
    gid    => $gid,
  }->
  user { $user :
    ensure   => 'present',
    comment  => $comment,
    uid      => $uid,
    gid      => $group,
    groups   => $groups,
    home     => "${homedir}",
    require  => Group[$groups],
  }->
  file { "${homedir}" :
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    mode    => '0755',
  }->
  file { "${homedir}/.ssh" :
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    mode    => '0700',
  }
  if $rsa {
    file { "${homedir}/.ssh/id_rsa" :
      ensure  => 'file',
      owner   => $user,
      group   => $group,
      mode    => '0600',
      source  => $rsa
    }->
    file { "${homedir}/.ssh/id_rsa.pub" :
      ensure  => 'file',
      owner   => $user,
      group   => $group,
      mode    => '0644',
      source  => "${rsa}.pub",
    }
    file { "${homedir}/.ssh/authorized_keys" :
      ensure  => 'file',
      owner   => $user,
      group   => $group,
      mode    => '0600',
      source  => "${rsa}.pub",
    }
  }
  if $libvirt { 
    policykit::localauthority { "${user}-libvirt-management" :
      identity        => "unix-user:${user}",
      action          => 'org.libvirt.unix.manage',
      result_active   => 'yes',
      result_any      => 'yes',
      result_inactive => 'yes',
    }
  }
}
