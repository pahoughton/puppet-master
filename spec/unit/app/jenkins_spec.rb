# jenkins_spec.rb - 2014-03-09 11:01
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

$username = 'paul'

$os_family = {
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}
$config_fn = {
  'Fedora' => '/etc/sysconfig/jenkins',
  'CentOS' => '/etc/sysconfig/jenkins',
  'Ubuntu' => '/etc/sysconfig/jenkins',
}
# no Ubuntu support yet  
['Fedora','CentOS',].each { |os|
  describe 'master::app::jenkins', :type => :class do

    let(:facts) do {
        :osfamily  => $os_family[os],
        :operatingsystem => os,
    } end 

    context "supports operating system: #{os}" do
      context "provides master::app::jenkins class which" do
        it { should contain_class('master::app::jenkins') }
        it { should contain_file($config_fn[os]) }
        it { should contain_service('jenkins') }
        context "default params" do
          it { should contain_file('/srv/jenkins') }
        end
        context "specified params" do
          let :params do {
              :basedir => '/home/www/jenkins',
              :port    => '1234',
          } end
          it { should contain_file('/home/www/jenkins') }
          it { should contain_file($config_fn[os]).
                 with_content(/1234/) }
          # not sure how to get this to work w/o vhost definition
          # it { should contain_nginx__resource__location('jenkins_proxy') }
        end
      end
    end
  end
}
