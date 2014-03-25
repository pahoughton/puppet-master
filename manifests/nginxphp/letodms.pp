# letodms.pp - 2014-01-27 19:09
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::nginxphp::letodms (
  $app = 'letodms',
  $tarball = 'letodms.tar.gz',
  $db_host = 'localhost',

  # settings.xml values
  $sitename = 'wxocdms',
  $rootdir = '/var/www/letodms',
  $httproot = 'letodms',
  $contentdir = '/var/www/letodms/data',
  $ldaphost = undef,
  $msadhost = 'codenlog01.cable.comcast.com',
  $basedn = 'OU=West Division,DC=cable,DC=comcast,DC=com',
  $accountdomain = 'cable.comcast.com',
  ) {

  master::nginxphp::app { $app :
    appdir      => $app,
    db_host     => $db_host,
    db_name     => $app,
    db_user     => $app,
    db_pass     => $app,
  }
  file { "/var/www/${tarball}" :
    ensure  => 'file',
    owner   => $master::nginxphp::www_user,
    group   => $master::nginxphp::www_group,
    source  => "puppet:///modules/master/${tarball}",
    require => File[$master::nginxphp::basedir],
    notify  => Exec["extract ${app} tar"],
  }
  exec { "extract ${app} tar" :
    command => "/bin/tar xzf /var/www/${tarball}",
    cwd     => $master::nginxphp::basedir,
    user    => $master::nginxphp::www_user,
    group   => $master::nginxphp::www_group,
    creates => '/var/www/letodms/letodms/index.php',
  }
  ->
  file { "${rootdir}/${httproot}/conf/settings.xml" :
    ensure  => 'present',
    content => template('master/letodms/settings.xml.erb'),
    owner   => $master::nginxphp::www_user,
    group   => $master::nginxphp::www_group,
    mode    => '0664',
  }
}
