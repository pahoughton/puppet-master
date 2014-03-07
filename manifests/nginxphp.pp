# nginxphp.pp - 2014-02-19 07:36
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::nginxphp (
  $basedir     = '/var/www',
  $vhost       = 'localhost',
  $php_modules = undef,
  $www_user    = 'nginx',
  $www_group   = 'nginx'
  ) {
  
  class { 'nginx' : }

  # ubuntu has seperate ini for php-fpm
  if $::osfamily == 'debian' {
    php::ini { '/etc/php5/fpm/php.ini' :
      display_errors  => 'On',
      short_open_tag  => 'Off',
      date_timezone   => 'America/Denver',
    }
  }
  php::ini { '/etc/php.ini' :
    display_errors  => 'On',
    short_open_tag  => 'Off',
    date_timezone   => 'America/Denver',
  }
  class { 'php::cli' : }
  class { 'php::fpm::daemon' : }
  php::fpm::conf { 'www' :
    listen  => '127.0.0.1:9000',
    user    => 'nginx',
    group   => 'nginx',
    require => Package['nginx'],
  }
  if $php_modules {
    php::module { $php_modules : }
  }
  $php_base_dir = $::osfamily ? {
    'debian'  => '/var/lib/php5',
    'redhat'  => '/var/lib/php',
  }
   file { $basedir :
    ensure => 'directory',
    owner   => $www_user,
    group   => $www_group,
    mode    => '0775',
    require => Package['nginx'],
  }->
  file { '/var/www/phpinfo.php' :
    ensure => 'file',
    owner   => $www_user,
    group   => $www_group,
    content => "<?php phpinfo(); ?>\n",
  }
  file { '/var/lib/php/session' :
    ensure => 'directory',
    owner   => $www_user,
    group   => $www_group,
    mode    => '0775',
  }
  # Perl Fast CGI
  $perl_fcgi_pkgs = $::osfamily ? {
    'redhat' => 'perl-FCGI',
    'debian' => 'libfcgi-perl',
    default  => undef
  }
  package { $perl_fcgi_pkgs :
    ensure => 'installed',
  }
  ->
  file { '/usr/sbin/perl-fcgi.pl' :
    ensure => 'file',
    mode   => '0755',
    source => 'puppet:///modules/master/perl-fcgi/perl-fcgi-wrapper.pl'
  }
  file { "${basedir}/perl-fcgi-test.pl" :
    ensure => 'file',
    mode   => '0755',
    source => 'puppet:///modules/master/perl-fcgi/perl-fcgi-test.pl'
  }
  
  nginx::resource::vhost { $vhost :
    ensure      => 'present',
    www_root    => $basedir,
    index_files => ['index.php',],
  }    
}
