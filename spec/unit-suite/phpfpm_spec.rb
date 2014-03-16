# phpfpm_spec.rb - 2014-03-10 09:39
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
['Fedora','CentOS','Ubuntu'].each { |os|
  describe 'master::phpfpm', :type => :class do

    let(:facts) do {
        :osfamily  => $os_family[os],
        :operatingsystem => os,
    } end 

    context "supports operating system: #{os}" do
      context "provides master::phpfpm class which" do
        it { should contain_class('master::phpfpm') }
        it { should contain_php__ini('/etc/php.ini') }
        it { should contain_class('php::cli') }
        it { should contain_class('php::fpm::daemon') }
        it { should contain_php__fpm__conf('www').with(
            'listen' => '127.0.0.1:9000',
            'user'   => 'nginx',
            'group'  => 'nginx',
          )
        }
      end
    end
  end
}
