# perlfcgi.pp - 2014-03-09 10:33
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::perlfcgi (
  $testdir = undef,
  ) {

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
  if $testdir {
    file { "${testdir}/perl-fcgi-test.pl" :
      ensure => 'file',
      mode   => '0755',
      source => 'puppet:///modules/master/perl-fcgi/perl-fcgi-test.pl'
    }
  }
}
