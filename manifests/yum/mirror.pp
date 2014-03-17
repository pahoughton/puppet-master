# mirror.pp - 2014-03-02 06:35
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# Create a yum repo mirror
class master::yum::mirror (
  $keepcache = '1',
  $cache_dir = '/var/cache/yum'
  ) {

  file { '/etc/yum.conf' :
    ensure  => 'file',
    mode    => '0644',
    content => template('master/yum.conf.erb'),
  }
  package { 'createrepo' :
    ensure => 'installed'
  }
  file { ['/var/lib/yum/mirrors','/var/lib/yum/mirrors/fedora'] :
    ensure => 'directory',
  }->
  exec { 'create repo' :
    command => 'createrepo --database /var/lib/yum/mirrors/fedora',
  }
}
