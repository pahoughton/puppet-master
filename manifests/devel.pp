# devel.pp - 2014-02-15 22:02
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
class master::devel {

  if ! defined(Class['master::php::composer']) {
    class { 'master::php::composer' : }
  }
  if ! defined(Class['gcc']) {
    class { 'gcc' : }
  }
  if ! defined(Class['python']) {
    class { 'python' : }
  }

  $pkgs = [ 'flex',
            'git-svn',
            'meld',
            'python-virtualenv',
            ]

  $ofpkgs = $::osfamily ? {
    'RedHat' => [ 'emacs-el',
                  'libyaml-devel',
                  'postgresql-devel',
                  'ruby-devel',
                  'rubygem-rake',
                  'yum-utils',
                  ],
    'Debian' => [ 'emacs24-el',
                  'libyaml-dev',
                  'libpq-dev',
                  'mysql-client',
                  'puppet-lint',
                  'rake',
                  'ruby-rspec-puppet',
                  'ruby-full',
                  ],
    default  => [],
  }
  $ospkgs = $::operatingsystem ? {
    'Fedora' => [ 'libxml2-devel',
                  'libxslt-devel',
                  'mariadb-devel',
                  'rubygem-nokogiri',
                  ],
    'CentOS' => ['mysql-devel','man-pages'],
    default  => [],
  }

  ensure_packages($pkgs)
  ensure_packages($ofpkgs)
  ensure_packages($ospkgs)

  $gems = [ 'bundler',
            'librarian-puppet',
            'puppet-syntax',
            'rspec-core',
            'rspec-expectations',
            'rspec-mocks'
            ]
  $ofgems = $::osfamily ? {
    'RedHat' => [ 'puppet-lint',
                  'rspec-puppet',
                  ],
    default  => [],
  }

  ensure_resource('package',$gems,{
    provider => 'gem',
    require  => [ Package[$pkgs],
                  Package[$ofpkgs],
                  Package[$ospkgs],
                  ]
  })
  ensure_resource('package',$ofgems,{
    provider => 'gem',
    require  => [ Package[$pkgs],
                  Package[$ofpkgs],
                  Package[$ospkgs],
                  ]
  })

  $perlmods = [ 'DBD::mysql',
                'DBD::Pg',
                'PHP::Serialization',
                ]

  perl::module { $perlmods :  }

  if ! defined( Php__Module['pgsql'] ) {
    php::module { 'pgsql' : }
  }

  # fixme - dup w/ php module
  # if ! defined(Class['php::cli']) {
  #   class { 'php::cli' : }
  # }
  # $ofphpmods = $::osfamily ? {
  #   'RedHat' => ['pdo'],
  #   default  => [],
  # }

  # php::module { $ofphpmods : }
  # php::module { 'mysqlnd' : }
}
