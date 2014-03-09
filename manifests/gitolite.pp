# paul.pp 2014-02-15 03:25
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::gitolite (
  $user       = 'git',
  $group      = 'git',
  $basedir    = '/var/lib/gitolite',
  $source     = 'https://github.com/sitaramc/gitolite',
  $version    = undef,
  $admin_key,
  $package    = 'gitolite',
  $bacula_dir = undef,
  
  ) {
  # We roll our own to get access to gl-admin-push from latest code
  package { $package: ensure => absent }

  # Create user/group at install to have a dir to unpack in
  group { $group:
    ensure  => 'present',
  }->
  user { $user:
    ensure  => 'present',
    gid     => $group,
    home    => $basedir,
    shell   => '/bin/bash',
    comment => 'Gitolite user',
  }->
  file { [$basedir,"${basedir}/bin"]:
    ensure  => directory,
    mode    => 'g+s',
    owner   => $user,
    group   => $group,
    require => User[$user]
  }->
  vcsrepo { "${basedir}/gitolite" :
    provider   => 'git',
    ensure     => 'present',
    source     => $source,
    revision   => $version,
    owner      => $user, 
    group      => $group,
  }->
  file { "${basedir}/${admin_key}" :
    ensure  => 'file',
    owner   => $user,
    group   => $group,
    source  => "puppet:///extra_files/${admin_key}",
  }->
  exec { "install gitolite" :
    command     => "${basedir}/gitolite/install -ln",
    environment => ["HOME=${basedir}",],
    user        => $user,
    group       => $group,
    cwd         => $basedir,
    creates     => "${basedir}/bin/gitolite",
  }->
  exec { "gitolite admin setup" :
    command     => "${basedir}/bin/gitolite setup -pk ${basedir}/${admin_key}",
    environment => ["HOME=${basedir}",],
    user        => $user,
    group       => $group,
    cwd         => $basedir,
    creates     => "${basedir}/.gitolite/conf/gitolite.conf",
  }->
  file { "${basedir}/.gitolite.rc" :
    ensure  => 'file',
    owner   => $user,
    group   => $group,
    source  => 'puppet:///modules/master/gitolite.rc',
  }->
  file { "${basedir}/.gitolite/hooks/common/post-receive" :
    ensure  => 'file',
    owner   => $user,
    group   => $group,
    source  => 'puppet:///modules/master/gitolite-hook-default-post-receive',
  }
}
