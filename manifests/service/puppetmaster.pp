# puppetmaster.pp - 2014-01-26 05:22
#
# Copyright (c) 2014  <paul4hough@gmail.com>
#
class master::service::puppetmaster {

  package { ['puppet-server',] :
    ensure => 'installed',
  }->
  service { ['puppetmaster'] :
    ensure => 'running',
    enable => true,
  }->
  file { '/etc/puppet' :
    ensure => 'directory',
    mode   => 'g+ws',
  }
  if ! defined( Package['librarian-puppet']) {
    package { 'librarian-puppet' :
      ensure   => 'installed',
      provider => 'gem',
      require  => Package['puppet-server'],
    }
  }
  if $::operatingsystem == 'Fedora' {
    service { 'firewalld' :
      ensure => 'running',
      enable => true,
    }->
    exec { 'open port 8140 for puppet' :
      command => '/bin/firewall-cmd --permanent --zone=public --add-port=8140/tcp'
    }
  } else {
    fail("only fedora supported: ${::operatingsystem}")
  }
  file { '/root/scripts/puppet.update.bash' :
    ensure  => 'file',
    mode    => '0755',
    source  => 'puppet:///modules/master/puppet.update.bash',
  }
  file { '/root/scripts/puppet.apply.bash' :
    ensure  => 'file',
    mode    => '0755',
    source  => 'puppet:///modules/master/puppet.apply.bash',
  }
}
