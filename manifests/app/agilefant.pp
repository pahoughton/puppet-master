# agilefant.pp - 2014-03-18 14:29
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# Fixme - http://java.sun.com/jsp/jstl/fmt cannot be resolved
class master::app::agilefant (
  $vhost      = 'localhost',
  $tomcatport = undef,
  $app        = 'agilefant',
  $warurl     = undef, # wget ${uris[app]}/agilefant-3.4/agilefant.war
  $db_create  = true,
  $db_host    = undef, # hiera databases['$app']['host']
  $db_name    = undef,
  $db_user    = undef,
  $db_pass    = undef,
  $tomcatdir  = '/srv/webapps',
  $tomcatuser = 'tomcat',
  $tomcatgrp  = 'tomcat',
  ) {

  $dhost = $db_host ? { undef => 'localhost', default => $db_host }
  $dname = $db_name ? { undef => $app, default => $db_name }
  $duser = $db_user ? { undef => $app, default => $db_user }
  $dpass = $db_pass ? { undef => $app, default => $db_pass }
  $tport = $tomcatport ? { undef => '8080', default => $tomcatport }
  $tuser = $tomcatuser ? { undef => 'tomcat', default => $tomcatuser }
  $tgrp = $tomcatgrp ? { undef => 'tomcat', default => $tomcatgrp }
  $tdir = $tomcatdir ? { undef => '/srv/webapps', default => $tomcatdir }


  $databases   = hiera('databases',{ 'agilefant' => { 'host' => $dhost,
              'name' => $dname,
              'user' => $duser,
              'pass' => $dpass, },})

  $directories = hiera('directories',{ 'tomcat' => $tdir })
  $groups      = hiera('groups',{ 'tomcat' => $tgrp })
  $ports       = hiera('ports',{ 'tomcat' => $tport })
  #$servers    = hiera('servers')
  $uris        = hiera('uris',{ 'app' => undef } )
  $users       = hiera('users',{ 'tomcat' => $tuser })

  $url = $warurl ? {
    undef   => "${uris[app]}/agilefant-3.4/agilefant.war",
    default => $warurl,
  }

  Exec {
    user    => $users['tomcat'],
    group   => $groups['tomcat'],
    require => Class['master::app::tomcatbase'],
  }
  class { 'master::app::tomcatbase' :
    vhost     => $vhost,
    tport     => $ports['tomcat'],
    app       => $app,
    tomcatdir => $directories['tomcat'],
  }

  if $db_create {
    mysql::db { $databases[$app]['name'] :
      host     => '%',
      user     => $databases[$app]['user'],
      password => $databases[$app]['pass'],
      grant    => ['ALL',],
    }
  }
  exec { 'fetch-agilefant' :
    cwd      => $directories['tomcat'],
    command  => "wget ${url}",
    creates  => "${directories['tomcat']}/agilefant.war",
    notify   => Service['tomcat'],
    require  => File[$directories['tomcat']],
  }
  ->
  exec { 'extract-agilefant' :
    cwd      => $tomcatdir,
    command  => 'unar agilefant.war',
    creates  => "${directories[tomcat]}/agilefant",
    notify   => Service['tomcat'],
    require  => File[$directories['tomcat']]
  }
  ->
  file { "${tomcatdir}/agilefant/WEB-INF/agilefant.conf" :
    ensure  => 'file',
    owner   => $users['tomcat'],
    group   => $groups['tomcat'],
    content => template('master/app/agilefant.conf.erb'),
    notify  => Service['tomcat'],
  }
}
