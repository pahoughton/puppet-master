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
os_rel = {
  'Fedora' => '20',
  'CentOS' => '6',
  'Ubuntu' => '13',
}

tobject   = 'master::app::agilefant'
os        = 'Fedora' # os independent, using template code
tomcatdir = '/srv/webapps' # default

describe tobject, :type => :class do
  tfacts = {
    :osfamily               => os_family[os],
    :operatingsystem        => os,
    :operatingsystemrelease => os_rel[os],
    :os_maj_version         => os_rel[os],
  }
  let(:facts) do tfacts end
  context "supports facts #{tfacts}" do
    #it { should compile } #?- fail: expected that the catalogue would include
    it { should contain_class(tobject) }
    context "params default" do
      it { should contain_class('master::app::tomcatbase').
        with( 'vhost'     => 'localhost',
              'tport'     => '1230', # from hiera/common.json
              'app'       => 'agilefant',
              'tomcatdir' => '/srv/webapps')
      }
      it { should contain_mysql__db('agilefant').
        with( 'host'     => '%',
              'password' => 'tagile',)
      }
      it { should contain_exec('extract-agilefant').
        with( 'notify'  => 'Service[tomcat]',
              'require' => "File[#{tomcatdir}]",
              'user'    => 'tomcat',
              'group'   => 'tomcat' )
      }
      it { should contain_file("#{tomcatdir}/agilefant/WEB-INF/agilefant.conf").
        with( 'content' => /pass.*tagile/ )
      }
    end
  end
end
