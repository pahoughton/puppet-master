# master-client-oracle_spec.rb - 2014-03-30 08:54
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

tobject  = 'master::client::oracle'
os       = 'Fedora'
pkg      = 'oracle-instclnt-12.1-sdk.tar.gz'
tappuri  = 'http://tappshost/mirrors/apps'
tinstdir = '/srv/oracle'

describe tobject, :type => :class do
  tfacts = {
    :osfamily               => os_family[os],
    :operatingsystem        => os,
    :operatingsystemrelease => os_release[os],
    :os_maj_version         => os_release[os],
  }
  let(:facts) do tfacts end
  context "supports facts #{tfacts}" do
    #it { should compile } #?- fail: expected that the catalogue would include
    [tobject,
    ].each { |cls|
      it { should contain_class(cls) }
    }
    it { should contain_file("#{tinstdir}/install") }
    it { should contain_exec("tar xzf #{tinstdir}/install/#{pkg}") }
  end
end
