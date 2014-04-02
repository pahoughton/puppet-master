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
  $shell   = '/bin/bash',
  $rsa     = undef,
  $libvirt = undef,
  ) {

  $user    = $name
  $pgroup = $group ? {
    undef   => $user,
    default => $group,
  }
  $homedir = $home ? {
    undef   => "/home/${user}",
    default => $home,
  }

  File {
    owner   => $user,
    group   => $pgroup,
  }

  group { $pgroup :
    ensure => 'present',
    gid    => $gid,
  }
  user { $user :
    ensure   => 'present',
    comment  => $comment,
    uid      => $uid,
    gid      => $pgroup,
    groups   => $groups,
    home     => $homedir,
    shell    => $shell,
    require  => Group[$pgroup],
  }->
  file { $homedir :
    ensure  => 'directory',
    mode    => '0755',
  }->
  file { "${homedir}/.ssh" :
    ensure  => 'directory',
    mode    => '0700',
  }
  $gitconfig_tmpl = $::operatingsystem ? {
    'CentOS' => 'master/users/gitconfig-old.erb',
    default  => 'master/users/gitconfig.erb',
  }
  file { "${homedir}/.gitconfig" :
    ensure  => 'file',
    mode    => '0644',
    content => template($gitconfig_tmpl),
    require => File[$homedir],
  }

  if $rsa {
    file { "${homedir}/.ssh/id_rsa" :
      ensure  => 'file',
      mode    => '0600',
      source  => $rsa
    }->
    file { "${homedir}/.ssh/id_rsa.pub" :
      ensure  => 'file',
      mode    => '0644',
      source  => "${rsa}.pub",
    }
    file { "${homedir}/.ssh/authorized_keys" :
      ensure  => 'file',
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
