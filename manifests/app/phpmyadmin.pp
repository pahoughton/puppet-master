# phpmyadmin.pp - 2014-04-05 04:16
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::app::phpmyadmin(
  $appname = 'phpmyadmin' , # /srv/www/phpmysql & http://host/phpmysql
  $prefix  = undef, # $prefix/$appname
  $tarball = 'phpmyadmin-4.1.12.tar.gz',
  $source  = undef, # http://apprepo/$tarball - download
  $user    = undef, # file/dir owner
  $group   = undef, # file/dir group
  ) {

  $directories = hiera('directories',{'www' => '/srv/www'})
  $groups      = hiera('groups',{'www' => 'www'})
  $servers     = hiera('servers',{'app' => 'http://appsrv/apps' })
  $users       = hiera('users',{'www' => 'www'})

  $appsrc = $source ? {
    undef   => $servers['app'],
    default => $source,
  }

  $wwwdir = $prefix ? {
    undef   => $directories['www'],
    default => $prefix,
  }
  $appgroup = $group ? {
    undef   => $groups['www'],
    default => $group,
  }
  $appuser = $user ? {
    undef   => $users['www'],
    default => $user,
  }

  Exec {
    user  => $appuser,
    group => $appgroup,
  }
  File {
    owner => $appuser,
    group => $appgroup,
  }

  exec { "wget ${appsrc}/${tarball}" :
    cwd     => $wwwdir,
    creates => "${wwwdir}/${tarball}",
  }
  ->
  exec { "unar ${tarball}" :
    cwd     => $wwwdir,
    creates => "${wwwdir}/${appname}",
  }
  ->
  file { "${wwwdir}/${appname}/config.ini.php" :
    ensure  => 'file',
    content => template('master/app/phpmyadmin-config.inc.php.erb'),
  }
  php::module { 'mysqli' : }
}
