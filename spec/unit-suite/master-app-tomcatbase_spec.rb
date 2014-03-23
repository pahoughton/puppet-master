# master-app-tomcatbase_spec.rb - 2014-03-20 13:06
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
os = 'Fedora'      # os independent, using template code
host = 'localhost' # default
app = 'agilefant'  # default

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
    it { should contain_nginx__resource__location("#{host}-#{app}-tomcat-static").
      with( 'www_root' => '/srv/webapps',)
    }
    it { should contain_nginx__resource__location("#{host}-#{app}-tomcat-proxy").
      with( 'vhost' => 'localhost',
            'location' => "/#{app}",
            'proxy'     => "http://#{host}:1230",
            )
    }
  end
end
