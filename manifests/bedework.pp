# bedework.pp - 2014-02-25 13:11
#
# Copyright (c) 2014 Paul Houghton <paul_houghton@cable.comcast.com>
#
class master::bedework (
  $tarball = 'bedework.tar.gz',
  ) {

  class { 'java' : }

  $java_home = $::osfamily ? {
    'debian'  => '/usr/lib/jvm/java-7-openjdk-i386',
    default   => undef,
  }
  
  file { "/root/runbedework" :
    ensure  => 'file',
    content => template('master/runbedework.erb'),
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
    creates => '/var/www/bedework/VERSION',
  }
  
}
