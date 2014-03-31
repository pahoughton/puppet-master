# paul.pp 2014-02-15 03:25
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::service::gitolite (
  $user          = 'git',
  $group         = 'git',
  $basedir       = '/srv/gitolite',
  $source        = 'http://github.com/sitaramc/gitolite',
  $version       = undef,
  $admin_key     = undef,
  $admin_key_src = undef,
  $package       = 'gitolite',
  ) {
  # We roll our own to get access to gl-admin-push from latest code
  package { $package: ensure => absent }
  File {
    owner   => $user,
    group   => $group,
  }
  Exec {
    user    => $user,
    group   => $group,
  }
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
  file { ["${basedir}/.bash_profile",
          "${basedir}/.bashrc",] :
    ensure  => 'file',
    content => "PATH=\$HOME/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin\n",
  }
  file { [$basedir,"${basedir}/bin"]:
    ensure  => directory,
    mode    => 'g+s',
    require => User[$user]
  }->
  vcsrepo { "${basedir}/gitolite" :
    ensure     => 'present',
    provider   => 'git',
    source     => $source,
    revision   => $version,
    owner      => $user,
    group      => $group,
  }->
  file { "${basedir}/${admin_key}" :
    ensure  => 'file',
    source  => "puppet:///extra_files/${admin_key}",
  }->
  exec { 'install gitolite' :
    command     => "${basedir}/gitolite/install -ln",
    environment => ["HOME=${basedir}",],
    cwd         => $basedir,
    creates     => "${basedir}/bin/gitolite",
  }->
  exec { 'gitolite admin setup' :
    command     => "${basedir}/bin/gitolite setup -pk ${basedir}/${admin_key}",
    environment => ["HOME=${basedir}",],
    cwd         => $basedir,
    creates     => "${basedir}/.gitolite/conf/gitolite.conf",
  }->
  file { "${basedir}/.gitolite.rc" :
    ensure  => 'file',
    source  => 'puppet:///modules/master/gitolite.rc',
  }->
  file { "${basedir}/.gitolite/hooks/common/post-receive" :
    ensure  => 'file',
    mode    => '0755',
    source  => 'puppet:///modules/master/gitolite-hook-default-post-receive',
  }
}
