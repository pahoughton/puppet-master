# master-devel_spec.rb - 2014-03-09 09:40
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

osfamily_pkgs = {
  'redhat' => [ 'yum-utils',
                'man-pages',
                'emacs-el',
                'ruby-devel',],
  'debian' => [ 'libpq-devel',
                'mysql-client',
                'emacs24-el',
                'ruby-full',],
}
os_pkgs = {
  'Fedora' => ['mariadb-devel',
               'rubygem-nokogiri',
               'libxml2-devel',
               'libxslt-devel',],
  'CentOS' => ['mysql-devel',],
  'Ubuntu' => [],
}
os_family = {
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}

common_pkgs = ['git-svn',
               'flex',
               'libyaml-devel',
               'meld',
               'rspec-core',
               'puppet-gem',
               'python-virtualenv',
               'rspec-mocks',
               'rspec-expectations',
              ]
perl_modules = ['DBD::mysql',
                'DBD::pg',]

tobject = 'master::devel'
['Fedora','CentOS','Ubuntu'].each { |os|
  describe tobject, :type => :class do
    tfacts = {
      :osfamily        => os_family[os],
      :operatingsystem => os,
    }
    let(:facts) do tfacts end
    context "supports facts #{tfacts}" do
      [tobject,
       'python',].each{ |cls|
        it { should contain_class(cls) }
      }
      it { should contain_class(tobject) }
      context "installs devel packages" do
        osfamily_pkgs[os_family[os]].each{|pkg|
          it { should contain_package(pkg) }
        }
        os_pkgs[os].each {|pkg|
          it { should contain_package(pkg) }
        }
        common_pkgs.each {|pkg|
          it { should contain_package(pkg) }
        }
        perl_modules.each { |pm|
          it { should contain_perl__module(pm) }
        }
      end
    end
  end
}
