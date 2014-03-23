# agilefant.pp - 2014-03-18 14:29
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# Fixme - http://java.sun.com/jsp/jstl/fmt cannot be resolved
class master::app::agilefant (
  $vhost     = 'localhost',
  $tport     = undef,
  $app       = 'agilefant',
  $db_host   = undef,
  $mydb_name = 'agilefant',
  $tomcatdir = '/srv/webapps',
  ) {

  $passwords = hiera('passwords',{})
  $servers = hiera('servers')
  $ports = hiera('ports',{ 'tomcat' => '8080' } )

  # fixme - tomcatbase some how?
  Exec {
    user    => 'tomcat', # $master::app::tomcatbase::user,
    group   => 'tomcat', # $master::app::tomcatbase::group,
    require => Class['master::app::tomcatbase'],
  }
  $port = $tport ? {
    undef   => $ports['tomcat'],
    default => $tport,
  }
  if ! $port {
    fail('need tport (tomcat port) value, hiera ports:tomcat not defined')
  }
  class { 'master::app::tomcatbase' :
    vhost     => $vhost,
    tport     => $port,
    app       => $app,
    tomcatdir => $tomcatdir,
  }

  $mydb_host = $db_host ? {
    undef   => $servers['mysql'],
    default => $db_host,
  }

  $mydb_user = 'agilefant'
  $mydb_pass = $passwords['mysql-agilefant']
  if $mydb_host == $::hostname or $mydb_host == 'localhost' {
    mysql::db { $mydb_name :
      host     => $mydb_host,
      user     => $mydb_user,
      password => $mydb_pass,
      grant    => ['ALL',],
    }
  }
  exec { 'fetch-agilefant' :
    cwd      => $tomcatdir,
    command  => "wget http://${servers[app]}/agilefant-3.4/agilefant.war",
    creates  => "${tomcatdir}/agilefant.war",
    notify   => Service['tomcat'],
    require  => File[$tomcatdir],
  }
  ->
  exec { 'extract-agilefant' :
    cwd      => $tomcatdir,
    command  => 'unar agilefant.war',
    creates  => "${tomcatdir}/agilefant",
    notify   => Service['tomcat'],
    require  => File[$tomcatdir],
  }
  ->
  file { "${tomcatdir}/agilefant/WEB-INF/agilefant.conf" :
    ensure  => 'file',
    owner   => 'tomcat',
    group   => 'tomcat',
    content => template('master/app/agilefant.conf.erb'),
    notify  => Service['tomcat'],
  }
}
