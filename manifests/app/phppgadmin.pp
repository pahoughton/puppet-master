# phppgadmin.pp - 2014-04-05 16:52
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::app::phppgadmin (
  $appname = 'phppgadmin' , # /srv/www/phpmysql & http://host/phpmysql
  $prefix  = undef, # $prefix/$appname
  $release = 'REL_5-1-0',
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
    undef   => $groups['www'][$::osfamily],
    default => $group,
  }
  $appuser = $user ? {
    undef   => $users['www'][$::osfamily],
    default => $user,
  }

  $pghost = $servers['pgsql']

  vcsrepo { "${wwwdir}/${appname}" :
    ensure     => 'present',
    source     => 'http://github.com/phppgadmin/phppgadmin',
    provider   => 'git',
    owner      => $appuser,
    group      => $appgroup,
    require    => [ File[$wwwdir],
                    Package[git],
                    Class['master::service::phpfpm'],
                    ],
  }
  ->
  file { "${wwwdir}/${appname}/conf/config.inc.php" :
    ensure  => 'file',
    owner   => $appuser,
    group   => $appgroup,
    content => template('master/app/phppgadmin-config.inc.php.erb'),
  }

  php::module { 'pgsql' : }

  # fixme this should notify php-fpm (if installed)
  # if ! defined( Php__Module['pgsql'] ) {
  #   php::module { 'pgsql' :
  #     notify => Service['php-fpm'],
  #   }
  # }
}
