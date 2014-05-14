# master-devel_spec.rb - 2014-03-09 09:40
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

tobject = 'master::devel'

supported = {
  'Debian' => {
    'undef' => ['undef',
               ],
  },
  'RedHat' => {
    'Fedora' => ['undef'
               ],
    'CentOS' => ['undef'
               ],
  },
}

lsbname = {
  'undef' => {
    'undef' =>  {},
  },
  'Debian' => {
    'undef' => {},
  },
  'RedHat' => {
    'Fedora' => {},
    'CentOS' => {},
  },
}

classes = {
  'Debian' => {
    'undef' => {
      'undef' => ['master::php::composer',
                 'gcc',
                 'python',
                 ],
    },
  },
  'RedHat' => {
    'Fedora' => {
      'undef' => ['master::php::composer',
                  'gcc',
                  'python',
                 ],
      },
    'CentOS' => {
      'undef' => ['master::php::composer',
                  'gcc',
                  'python',
                 ],
      },
  },
}

packages = {
  'Debian' => {
    'undef' => {
      'undef' => ['emacs24-el',
                  'libpq-devel',
                  'mysql-client',
                  'puppet-lint',
                  'puppet-syntax',
                  'rspec-mocks',
                  'ruby-rspec-puppet',
                  'ruby-full',
                  # common
                  'flex',
                  'git-svn',
                  'libyaml-dev',
                  'meld',
                  'python-virtualenv',
                  'rake',
                  ],
    },
  },
  'RedHat' => {
    'Fedora' => {
      'undef' => ['libxml2-devel',
                  'libxslt-devel',
                  'mariadb-devel',
                  'rubygem-nokogiri',
                  'emacs-el',
                  'postgresql-devel',
                  'ruby-devel',
                  'yum-utils',
                  # common
                  'flex',
                  'git-svn',
                  'libyaml-devel',
                  'meld',
                  'python-virtualenv',
                  'rake',
                  ],
    },
    'CentOS' => {
      'undef' => ['mysql-devel',
                  'man-pages',
                  'emacs-el',
                  'postgresql-devel',
                  'ruby-devel',
                  'yum-utils',
                  # common
                  'flex',
                  'git-svn',
                  'libyaml-devel',
                  'meld',
                  'python-virtualenv',
                  'rake',
                  ],
    },
  },
}

gems = {
  'Debian' => {
    'undef' => {
      'undef' => ['bundler',
                  'librarian-puppet',
                  'rspec-core',
                  'rspec-expectations',
                  'rspec-mocks',
                 ],
    },
  },
  'RedHat' => {
    'Fedora' => {
      'undef' => ['bundler',
                  'librarian-puppet',
                  'rspec-core',
                  'rspec-expectations',
                  'rspec-mocks',
                  'puppet-lint',
                  'rspec-puppet',
                 ],
    },
    'CentOS' => {
      'undef' => ['bundler',
                  'librarian-puppet',
                  'rspec-core',
                  'rspec-expectations',
                  'rspec-mocks',
                  'puppet-lint',
                  'rspec-puppet',
                 ],
    },
  },
}

perl_modules = ['DBD::mysql',
                'DBD::pg',
                'PHP::Serialization',
               ]
php_modules = ['pdo',
               'pgsql',
               'mysqlnd',
               ]

describe tobject, :type => :class do
  fam = 'Debian'
  os  = 'undef'
  rel = 'undef'
  tfacts = {
    :osfamily               => fam,
    :operatingsystem        => os,
    :operatingsystemrelease => rel,
    :os_maj_version         => rel,
    :lsbdistid              => os,
    :lsbdistcodename        => lsbname[fam][os][rel],
  }
  let(:facts) do tfacts end
  context "supports facts #{tfacts}" do
    perl_modules.each { |pm|
      it { should contain_perl__module(pm) }
    }
    php_modules.each { |pm|
      it { should contain_php__module(pm) }
    }
  end
end


supported.keys.each { |fam|
  osfam = supported[fam]
  osfam.keys.each { |os|
    osfam[os].each { |rel|
      describe tobject, :type => :class do
        tfacts = {
          :osfamily               => fam,
          :operatingsystem        => os,
          :operatingsystemrelease => rel,
          :os_maj_version         => rel,
          :lsbdistid              => os,
          :lsbdistcodename        => lsbname[fam][os][rel],
        }
        let(:facts) do tfacts end
        context "supports facts #{tfacts}" do
          #print "p:#{fam}:#{os}:#{rel}:#{packages[fam][os][rel]}\n"
          classes[fam][os][rel].each { |cls|
            it { should contain_class(cls) }
          }
          packages[fam][os][rel].each { |pkg|
            it { should contain_package(pkg) }
          }
          gems[fam][os][rel].each { |g|
            it { should contain_package(g).with('provider' => 'gem') }
          }
        end
      end
    }
  }
}
