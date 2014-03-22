# tomcat.pp - 2014-03-18 13:44
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::nginx::tomcat (
  $host       = 'localhost',
  $package    = 'tomcat',
  $service    = 'tomcat',
  $location   = '/tomcat',
  $tport      = undef,
  $sport      = undef,
  $webappsdir = '/srv/webapps/',
  ) {

  $ports = hiera('ports',{ 'tomcat' => '8080' })

  $port = $tport ? {
    undef   => $ports['tomcat'],
    default => $tport,
  }
  $sslport = $sport ? {
    undef   => $ports['tomcat-ssl'],
    default => $sport,
  }

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

  file { [$webappsdir,] :
    ensure  => 'directory',
    mode    => '0755',
    require => Package[$package],
  }
  file { '/usr/share/tomcat/webapps' :
    ensure  => 'link',
    target  => $webappsdir,
    require => File[$webappsdir],
  }
  file { '/etc/tomcat/server.xml' :
    ensure  => 'file',
    content => template('master/nginx-tomcat-server.xml.erb'),
  }
}
