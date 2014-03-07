# plans.pp - 2014-02-26 12:33
#
# Copyright (c) 2014 Paul Houghton <paul_houghton@cable.comcast.com>
#
class  master::app::plans (
  $app     = 'plans',
  $vhost   = 'localhost',
  $appdir  = 'plans',  
  $tarball = 'plans.tar.gz',
  $db_host = 'localhost',
  ) {

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
  nginx::resource::location { "${title}_cgi":
    ensure          => 'present',
    vhost           => $vhost,
    location        => "~ /${appdir}/(.*\.cgi)\$",
    www_root        => $master::nginxphp::basedir,
    proxy           => undef,
    fastcgi         => "127.0.0.1:8999",
  }
  # nginx::resource::location { "${title}_static":
  #   ensure          => 'present',
  #   vhost           => $vhost,
  #   location        => "~ /${appdir}/.*",
  #   www_root        => $master::nginxphp::basedir,
  #   proxy           => undef,
  # }  
  
}
