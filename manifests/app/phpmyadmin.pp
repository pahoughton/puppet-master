# phpmyadmin.pp - 2014-04-05 04:16
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::app::phpmyadmin (
  $appname = 'phpmyadmin' , # /srv/www/phpmysql & http://host/phpmysql
  $prefix  = undef, # $prefix/$appname
  $tarball = 'phpmyadmin-4.1.12.tar.gz',
  $source  = undef, # http://apprepo/$tarball - download
  $user    = undef, # file/dir owner
  $group   = undef, # file/dir group
  ) {

  $directories = hiera('directories',{'www' => '/srv/www'})
  $groups      = hiera('groups',{'www' =>  {'RedHat'=>'nginx','Debian'=>'www-data'}})
  $servers     = hiera('servers',{'pgsql' => 'localhost'})
  $users       = hiera('users',{'www' => {'RedHat'=>'nginx','Debian'=>'www-data'}})

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

  notify { 'fixme pending' : }
}
