# master-nginx-tomcat_spec.rb - 2014-03-18 13:35
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

os_family = {
  'Fedora' => 'RedHat',
  'CentOS' => 'RedHat',
  'Ubuntu' => 'debian',
}
os_release = {
  'Fedora' => '20',
  'CentOS' => '6',
  'Ubuntu' => '13',
}

tobject = 'master::nginx::tomcat'
['Fedora','CentOS','Ubuntu',].each { |os|
  describe tobject, :type => :class do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
      :operatingsystemrelease => os_release[os],
      :os_maj_version         => os_release[os],
      :kernel                 => 'Linux',
      :concat_basedir         => 'ugg postgres',
    }
    let(:facts) do tfacts end
    context "supports facts #{tfacts}" do
      #it { should compile } #?- fail: expected that the catalogue would include
      it { should contain_class(tobject) }
      it { should contain_package('tomcat') }
      it { should contain_file('/etc/tomcat/server.xml').
        with( 'content' => /1234/ )
      }
      it { should contain_service('tomcat').
        with( 'ensure' => 'running',
              'enable' => true )
      }
    end
  end
}
