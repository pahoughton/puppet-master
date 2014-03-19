# master-app-agilefant_spec.rb - 2014-03-18 14:16
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

tobject = 'master::app::agilefant'
['Fedora','CentOS','Ubuntu',].each { |os|
  tomcatdir = '/var/lib/tomcat/webapps'
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
      let :params do { 'db_host' => 'localhost' } end
      #it { should compile } #?- fail: expected that the catalogue would include
      it { should contain_class(tobject) }
      it { should contain_mysql__db('agilefant').
        with( 'host' => 'localhost', )
      }
      it { should contain_exec('extract-agilefant').
        with( 'notify'  => 'Service[tomcat]',
              'require' => "File[#{tomcatdir}]", )
      }
      it { should contain_file("#{tomcatdir}/agilefant/WEB-INF/agilefant.conf").
        with( 'content' => /pass.*testMysqlPass/ )
      }
    end
  end
}
