# devel.pp - 2014-02-15 22:02
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::devel {

  case $::osfamily {
    'redhat' : {
      case $::operatingsystem {
        'Fedora' : {
          $os_packages = ['mariadb-devel']
        }
        'CentOS' : {
          $os_packages = ['mysql-devel', 'man']
        }
        default : {
          fail("Unsupported os: ${::operatingsystem}")
        }
      }
      package { [ 'man-pages',
                  'yum-utils',
                  'emacs-el',
                  'gcc-c++',
                  'postgresql-devel',] :
                    ensure => 'installed',
      }
      package { $os_packages :
        ensure => 'installed',
      }
      $ruby_pkg = 'ruby-devel'
    }
    'debian' : {
      package { [ 'libpq-devel',
                  'mysql-client',
                  'emacs24-el',] :
        ensure => 'installed',
      }
      $ruby_pkg = 'ruby-full'
    }
    default : {
      fail('unsupported osfamily')
    }
  }

  package { [ 'git-svn',
              'meld' ] :
    ensure => 'installed'
  }
  class { 'gcc' : }
  # ruby stuff
  package { $ruby_pkg :
    ensure   => 'installed',
  }->
  package { 'rspec-core' :
    ensure   => 'installed',
    provider => 'gem',
  }->
  package { 'puppet-gem' :
    ensure    => 'installed',
    name      => 'puppet',
    provider  => 'gem',    
  }->
  package { [ 'rake',
              'bundler',
              'puppet-lint',
              'rspec-puppet',
              'puppetlabs_spec_helper',
              'puppet-syntax', ] :
    ensure    => 'installed',
    provider  => 'gem',
  }->
  package { 'rspec-mocks' :
    ensure   => 'installed',
    provider => 'gem',
  }->
  package { 'rspec-expectations' :
    ensure   => 'installed',
    provider => 'gem',
  # }->
  # package { 'rspec-system-serverspec' :
  #   ensure    => 'installed',
  #   provider  => 'gem',
  }

  class { 'nginx' :

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
  class { 'python' : }
}
