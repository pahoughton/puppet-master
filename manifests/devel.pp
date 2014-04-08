# devel.pp - 2014-02-15 22:02
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::devel {

  case $::osfamily {
    'redhat' : {
      case $::operatingsystem {
        'Fedora' : {
          $os_packages = ['mariadb-devel',
                          'rubygem-nokogiri',
                          'libxml2-devel',
                          'libxslt-devel', ]
        }
        'CentOS' : {
          $os_packages = ['mysql-devel']
        }
        default : {
          fail("Unsupported os: ${::operatingsystem}")
        }
      }
      ensure_packages([ 'man-pages',
                        'yum-utils',
                        'emacs-el',
                        'postgresql-devel',
                        ])
      ensure_packages( $os_packages )
      $ruby_pkg = 'ruby-devel'
    }
    'debian' : {
      ensure_packages(['libpq-devel',
                       'mysql-client',
                       'emacs24-el',])

      $ruby_pkg = 'ruby-full'
    }
    default : {
      fail('unsupported osfamily')
    }
  }

  if ! defined( Package['bundler'] ) {
    package { 'bundler' :
      ensure   => 'installed',
      provider => 'gem',
    }
  }

  ensure_packages( ['git-svn',
                    'flex',
                    'meld'] )

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
  package { [ 'rake', ] :
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
  }->
  package { 'rspec-system' :
    ensure    => 'installed',
    provider  => 'gem',
  }->
  package { 'rspec-system-puppet' :
    ensure    => 'installed',
    provider  => 'gem',
  }->
  package { 'rspec-system-serverspec' :
    ensure    => 'installed',
    provider  => 'gem',
  }

  package { [ 'puppet-lint',
              'rspec-puppet',
              'puppetlabs_spec_helper',
              'puppet-syntax', ] :
    ensure    => 'installed',
    provider  => 'gem',
  }

  if ! defined( Package['librarian-puppet'] ) {
    package { 'librarian-puppet' :
      ensure   => 'installed',
      provider => 'gem',
    }
  }
  class { 'python' : }
}
