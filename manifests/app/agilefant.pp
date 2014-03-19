# agilefant.pp - 2014-03-18 14:29
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# Fixme - http://java.sun.com/jsp/jstl/fmt cannot be resolved
class master::app::agilefant (
  $db_host    = undef,
  $mydb_name = 'agilefant',
  $tomcatdir = '/var/lib/tomcat/webapps/tomcat',
  ) {

  $passwords = hiera('passwords',{})
  $servers = hiera('servers')
  $mydb_pass = $passwords['mysql-agilefant']

  $mydb_host = $db_host ? {
    undef   => $servers['mysql'],
    default => $db_host,
  }
  mysql::db { $mydb_name :
    host     => $mydb_host,
    user     => 'agilefant',
    password => $mydb_pass,
    grant    => ['ALL',],
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
    command  => "unar agilefant.war",
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
