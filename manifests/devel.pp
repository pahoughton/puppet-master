# devel.pp - 2014-02-15 22:02
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::devel {

  $ofpkgs = $::osfamily ? {
    'RedHat' => [ 'emacs-el',
                  'postgresql-devel',
                  'ruby-devel',
                  'yum-utils',
                  ],
    'Debian' => [ 'emacs24-el',
                  'libpq-devel',
                  'mysql-client',
                  'puppet-lint',
                  'puppet-syntax',
                  'ruby-rspec-puppet',
                  'ruby-full',
                  ],
    default  => [],
  }
  $ospkgs = $::operatingsystem ? {
    'Fedora' => ['libxml2-devel',
                 'libxslt-devel',
                 'mariadb-devel',
                 'rubygem-nokogiri',
                 ],
    'CentOS' => ['mysql-devel','man-pages'],
    default  => [],
  }

  $pkgs = [ 'flex',
            'git-svn',
            'libyaml-devel',
            'meld',
            'python-virtualenv',
            'rake',
            ]

  $ofgems = $::osfamily ? {
    'RedHat' => [ 'puppet-lint',
                  'rspec-puppet',
                  ],
    default  => [],
  }

  $gems = ['bundler',
           'librarian-puppet',
           'rspec-core',
           'rspec-expectations',
           'rspec-mocks'
           ]

  if ! defined(Class['master::php::composer']) {
    class { 'master::php::composer' : }
  }
  if ! defined(Class['gcc']) {
    class { 'gcc' : }
  }
  if ! defined(Class['python']) {
    class { 'python' : }
  }
  if ! defined(Class['php::cli']) {
    php::ini { '/etc/php.ini' :
      display_errors  => 'On',
      short_open_tag  => 'Off',
      date_timezone   => 'America/Denver',
    }
    class { 'php::cli' : }
  }
  ensure_packages($ospkgs)
  ensure_packages($ofpkgs)
  ensure_packages($pkgs)
  ensure_resource('package',$ofgems,{
    provider => 'gem',
    require  => [Package[$ospkgs],
                 Package[$ofpkgs],
                 Package[$pkgs],
                 ]
  })
  ensure_resource('package',$gems,{
    provider => 'gem',
    require  => [Package[$ospkgs],
                 Package[$ofpkgs],
                 Package[$pkgs],
                 ]
  })


  perl::module { ['DBD::mysql',
                  'DBD::pg',
                  'PHP::Serialization',
                  ] :
  }

  if ! defined( Php__Module['pgsql'] ) {
    php::module { 'pgsql' : }
  }
  php::module { [ 'pdo',
                  'mysqlnd',] :
  }

}
