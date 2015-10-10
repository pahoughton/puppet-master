# 2015-10-10 (cc) <paul4hough@gmail.com>
#
# master-devel_spec.rb - 2014-03-09 09:40
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

tobject = 'master::devel::puppet'
# ttype = class;

supported = {
  'Debian' => {
    'undef' => ['undef',
               ],
  },
  'RedHat' => {
    'undef' => ['undef'],
  },
}

packages = {
  'Debian' => {
    'undef' => {
      'undef' => ['libyaml-dev',
                  'ruby-full',
                  # common
                  'bundler',
                  'librarian-puppet',
                  'puppet-syntax',
                  'rspec-core',
                  'rspec-expectations',
                  'rspec-mocks',
                  'puppet-lint',
                 ],
    },
  },
  'RedHat' => {
    'undef' => {
      'undef' => [ 'libyaml-devel',
                   'ruby-devel',
                   'yum-utils',
                   # common
                   'bundler',
                   'librarian-puppet',
                   'puppet-syntax',
                   'rspec-core',
                   'rspec-expectations',
                   'rspec-mocks',
                   'puppet-lint',
                 ],
    },
  },
}


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
        }
        let(:facts) do tfacts end
        context "supports facts #{tfacts}" do
          #print "p:#{fam}:#{os}:#{rel}:#{packages[fam][os][rel]}\n"
          packages[fam][os][rel].each { |pkg|
            it { should contain_package(pkg) }
          }
        end
      end
    }
  }
}
