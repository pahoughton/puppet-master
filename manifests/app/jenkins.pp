# jenkins.pp - 2014-03-01 10:25
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::app::jenkins (
  $basedir  = '/srv/jenkins',
  $user     = 'jenkins',
  $port     = '7237',
  $vhost    = undef,
  $location = '/jenkins'
  ) {
  case $::osfamily {
    'redhat' : {
      $keyfn = 'jenkins-ci.org.key'
      file { "/etc/pki/rpm-gpg/${keyfn}" :
        source => "puppet:///modules/master/$keyfn",
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
      ->
      package { 'jenkins' :
        ensure   => 'installed',
        require  => Class['java'],
      }
      $configfn = '/etc/sysconfig/jenkins'
      # fixme - add this to nginx as needed.
      exec { 'setsebool -P httpd_can_network_connect 1' :
        command => 'setsebool -P httpd_can_network_connect 1',
      }
    }
    default : {
      fail("unspported osfamily $::osfamily")
    }
  }
  file { $configfn :
    ensure  => 'file',
    mode    => '0644',
    content => template('master/jenkins/config.erb'),
    notify  => Service['jenkins'],
    require => Package['jenkins'],
  }
  file { $basedir :
    ensure  => 'directory',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0775',
    require => Package['jenkins'],
  }
  service { 'jenkins' :
    ensure  => 'running',
    enable  => true,
    require => [File['/etc/sysconfig/jenkins'],File[$basedir],],
  }
  if $vhost {
    nginx::resource::location { "jenkins_proxy":
      ensure              => 'present',
      vhost               => $vhost,
      location            => "~ ^${location}/",
      proxy               => "http://$vhost:$port",
      proxy_read_timeout  => undef,
      location_cfg_append => { include => '/etc/nginx/conf.d/proxy.conf' },
    }
  }
  
}
