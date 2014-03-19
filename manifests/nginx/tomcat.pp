# tomcat.pp - 2014-03-18 13:44
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::nginx::tomcat (
  $host       = undef,
  $package    = 'tomcat',
  $service    = 'tomcat',
  $location   = '/tomcat',
  $port       = '8080',
  $webappsdir = '/var/lib/tomcat/webapps/',
  ) {
  # todo - reconfig tomcat - look at tomcat puppet modules.
  # currently this is just the nginx tie in

  if $package {
    package { $package :
      ensure => 'installed',
    }
  } else {
    fail('package value required')
  }

  service { $service :
    ensure  => 'running',
    enable  => true,
    require => Package[$package],
  }

  file { [$webappsdir,"${webappsdir}${location}",] :
    ensure  => 'directory',
    mode    => '0755',
    require => Package[$package],
  }

  if ! $host {
    $vhost = 'localhost'
    nginx::resource::vhost { $vhost :
      ensure   => 'present',
      www_root => '/srv/www/',
    }
  } else {
    $vhost = $host
  }
  nginx::resource::location { "${vhost}-tomcat-static" :
    ensure              => 'present',
    vhost               => $vhost,
    location            => "~ ^${location}.*png\$",
    index_files         => undef,
    www_root            => $webappsdir,
  }
  nginx::resource::location { "${vhost}-tomcat-proxy" :
    ensure              => 'present',
    vhost               => $vhost,
    location            => "~ ^${location}.*",
    proxy               => "http://${vhost}:${port}",
    proxy_read_timeout  => undef,
    location_cfg_append => { include => '/etc/nginx/conf.d/proxy.conf' },
  }
}
