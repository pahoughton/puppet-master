# tiki.pp - 2014-02-23 10:47
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::nginxphp::app::tiki (
  $app = 'tiki',
  $tarball = 'tiki-12.0.tar.gz',
  $db_host = 'localhost',
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
    creates => '/var/www/tiki12/index.php',
  }

}
