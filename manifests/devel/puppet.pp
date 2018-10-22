# 2015-10-10 (cc) <paul4hough@gmail.com>
#
class master::devel::puppet {


  $ofpkgs = $::osfamily ? {
    'RedHat' => [ 'libyaml-devel',
                  'ruby-devel',
                  'yum-utils',
                  ],
    'Debian' => [ 'libyaml-dev',
                  'ruby-full',
                  ],
    default  => [],
  }


  ensure_packages($ofpkgs)

  $gems = [ 'bundler',
            'librarian-puppet',
            'puppet-syntax',
            'rspec-core',
            'rspec-expectations',
            'rspec-mocks',
            'puppet-lint',
            'rspec-puppet',
            ]

  ensure_resource('package',$gems,{
    provider => 'gem',
    require  => [ Package[$pkgs],
                  Package[$ofpkgs],
                  ]
  })
}
