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
  $groups      = hiera('groups',{'www' => 'www'})
  $servers     = hiera('servers',{'pgsql' => 'localhost'})
  $uris        = hiera('uris',{'app' => 'http://appsrv/apps' })
  $users       = hiera('users',{'www' => 'www'})

  $appsrc = $source ? {
    undef   => $uris['app'],
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
  # fixme this should notify php-fpm (if installed)
  php::module { 'pgsql' : }
}
