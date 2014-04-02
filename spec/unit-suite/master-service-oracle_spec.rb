# master-service-oracle_spec.rb - 2014-03-28 18:51
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

tobject = 'master::service::oracle'
os      = 'Fedora'
tappuri = 'http://tappshost/mirrors/apps'
tinstdir = '/srv/oracle/install'
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
    # fixme - broken
    # it { should contain_file(tinstdir) }
    # ['gcc-c++',
    #  'ksh',
    #  'libaio-devel',
    #  'libstdc++-devel',
    #  'xorg-x11-utils',
    #  #'',
    # ].each { |pkg|
    #   it { should contain_package(pkg) }
    # }
    # ['oracle-serv-1.zip',
    #  'oracle-serv-2.zip',
    # ].each { |zp|
    #   execcmd = "wget -q #{tappuri}/#{zp} && cd #{tinstdir} && unzip #{zp}"
    #   it { should contain_exec(execcmd) }
    # }
  end
end
