# jenkins.pp - 2014-03-01 10:25
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::app::jenkins (
  $vhost     = undef,
  $location  = '/jenkins',
  $wwwdir    = undef,
  $port      = undef,
  $cport     = undef,
  $appuser   = undef,
  $appgroup  = undef,
  ) {

  $directories = hiera('directories',{'www' => '/srv/www'})
  $email       = hiera('emails', { 'gitlab' => "gitlab@${::hostname}" })
  $groups      = hiera('groups',{'jenkins' => 'jenkins','www' => {'RedHat'=>'nginx','Debian'=>'www-data'}})
  $ports       = hiera('ports',{'jenkins' => '8180','jenkins-ctl' => '8180'})
  $users       = hiera('users', { 'git' => 'git', 'gitlab' => 'git','www' => {'RedHat'=>'nginx','Debian'=>'www-data'} })

  $basedir = $wwwdir ? {
    undef   => $directories['www'],
    default => $wwwdir,
  }
  $user = $appuser ? {
    undef   => $users['jenkins'],
    default => $appuser,
  }
  $group = $appgroup ? {
    undef   => $groups['jenkins'],
    default => $appgroup,
  }
  $pxyport = $port ? {
    undef   => $ports['jenkins'],
    default => $port,
  }
  $ctlport = $cport ? {
    undef   => $ports['jenkins-ctl'],
    default => $cport,
  }

  case $::osfamily {
    'RedHat' : {
      $configfn = '/etc/sysconfig/jenkins'
      $keyfn = 'jenkins-ci.org.key'
      file { "/etc/pki/rpm-gpg/${keyfn}" :
        source => "puppet:///modules/master/${keyfn}",
      }
      ->
      yumrepo { 'jenkins-ci' :
        descr       => 'jenkins-ci',
        baseurl     => 'http://pkg.jenkins-ci.org/redhat',
        enabled     => 1,
        gpgcheck    => 1,
        includepkgs => 'jenkins*',
        gpgkey      => "file:///etc/pki/rpm-gpg/${keyfn}",
      }
    }
    'Debian' : {
      $configfn = '/etc/default/jenkins'

      # apt::key { 'jenkins':
      # }
      # -> # todo - this should not be needed
      apt::source { 'jenkins':
        location    => 'http://pkg.jenkins-ci.org/debian',
        repos       => 'binary/',
        release     => ' ',
        key         => 'D50582E6',
        key_source  => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
        include_src => false,
        notify      => Exec['apt_get_update_for_nginx'],
      }
    }
    default : {
      fail("unspported osfamily ${::osfamily}")
    }
  }

  if $::selinux == 'true' {
    ensure_resource('selboolean','httpd_can_network_connect',{
      value => 'on',
    })
  }

  if ! defined(Class['java']) {
    class { 'java' : }
  }

  package { 'jenkins' :
    ensure   => 'installed',
    require  => Class['java'],
  }
  file { $configfn :
    ensure  => 'file',
    mode    => '0644',
    content => template("master/app/jenkins.${::osfamily}.erb"),
    notify  => Service['jenkins'],
    require => Package['jenkins'],
  }
  file { "${basedir}/jenkins" :
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    mode    => '0775',
    require => [File[$basedir],
                Package['jenkins'],]
  }
  service { 'jenkins' :
    ensure  => 'running',
    enable  => true,
    require => [File[$configfn],
                File["${basedir}/jenkins"],],
  }
  if ! defined(Class['nginx']) {
    class { 'nginx' : }
    ensure_resource('file',$basedir,{
      ensure  => 'directory',
      owner   => $users['www'][$::osfamily],
      group   => $groups['www'][$::osfamily],
      mode    => '0775',
      require => Class['nginx'],
    })
    if $vhost {
      nginx::resource::vhost { $vhost :
        ensure   => 'present',
        www_root => $basedir,
      }
    }
  }

  if $vhost and $location {
    nginx::resource::location { 'jenkins' :
      ensure              => 'present',
      vhost               => $vhost,
      location            => $location,
      proxy               => "http://${vhost}:${pxyport}",
      proxy_read_timeout  => undef,
      location_cfg_append => { include => '/etc/nginx/conf.d/proxy.conf' },
    }
  }
}
