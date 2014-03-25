# tiki.pp - 2014-02-23 10:47
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::nginxphp::tiki (
  $app     = 'tiki',
  $basedir = undef,
  $user    = undef,
  $group   = undef,
  $source  = 'puppet:///extra_files/',
  $tarball = 'tiki-12.0.tar.gz',
  $db_host = 'localhost',
  ) {

  $directories = hiera('directories',{ 'www' => '/srv/www' })
  $groups      = hiera('groups',{ 'www' => 'nginx' })
  $users       = hiera('users',{ 'www' => 'nginx' })

  $bdir = $basedir ? {
    undef   => $directories['www'],
    default => $basedir,
  }
  $agroup = $group ? {
    undef   => $groups['www'],
    default => $group,
  }
  $auser = $user ? {
    undef   => $users['www'],
    default => $user,
  }
  master::nginxphp::app { $app :
    basedir     => $bdir,
    db_host     => $db_host,
    db_name     => $app,
    db_user     => $app,
    db_pass     => $app,
  }
  file { "${bdir}/${tarball}" :
    ensure  => 'file',
    owner   => $auser,
    group   => $agroup,
    source  => "${source}/${tarball}",
    require => File[$bdir],
    notify  => Exec["extract ${app} tar"],
  }
  exec { "extract ${app} tar" :
    command => "tar xzf ${bdir}/${tarball}",
    cwd     => $bdir,
    user    => $auser,
    group   => $agroup,
    creates => "${bdir}/${app}/index.php",
  }
}
