# jenkins.pp - 2014-03-01 10:25
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::app::jenkins (
  $appdir    = undef,
  $appuser   = undef,
  $appgroup  = undef,
  $appport   = undef,
  $vhost     = undef,
  $location  = '/jenkins'
  ) {
  $directories = hiera('directories',{'jenkins' => '/var/lib/jenkins'})
  $email       = hiera('emails', { 'gitlab' => "gitlab@${::hostname}" })
  $groups      = hiera('groups',{'gitlab' => 'git' })
  $ports       = hiera('ports',{'jenkins' => '8180' })
  $servers     = hiera('servers',{'pgsql' => 'localhost','www' => undef } )
  $users       = hiera('users', { 'git' => 'git', 'gitlab' => 'gitlab', })

  $adir = $appdir ? {
    undef   => $directories['jenkins'],
    default => $appdir,
  }
  $user = $appuser ? {
    undef   => $users['jenkins'],
    default => $appuser,
  }
  $group = $appgroup ? {
    undef   => $groups['jenkins'],
    default => $appgroup,
  }
  $port = $appport ? {
    undef   => $ports['jenkins'],
    default => $appport,
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
      # fixme - add this to nginx as needed.
      exec { 'setsebool -P httpd_can_network_connect 1' :
        command => 'setsebool -P httpd_can_network_connect 1',
      }
    }
    'Debian' : {
      $configfn = '/etc/default/jenkins'

      # apt::key { 'jenkins':
      #   key        => 'D50582E6',
      #   key_source => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
      # }
      # -> # todo - this should not be needed
      apt::source { 'jenkins' :
        location    => 'http://pkg.jenkins-ci.org/debian',
        release     => '',
        repos       => 'binary/',
        include_src => false,
      }
    }
    default : {
      fail("unspported osfamily ${::osfamily}")
    }
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
  file { $adir :
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    mode    => '0775',
    require => Package['jenkins'],
  }
  service { 'jenkins' :
    ensure  => 'running',
    enable  => true,
    require => [File[$configfn],File[$adir],],
  }
  if $vhost {
    nginx::resource::location { 'jenkins' :
      ensure              => 'present',
      vhost               => $vhost,
      location            => $location,
      proxy               => "http://${vhost}:${port}",
      proxy_read_timeout  => undef,
      location_cfg_append => { include => '/etc/nginx/conf.d/proxy.conf' },
    }
  }
}
