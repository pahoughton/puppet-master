# perlfcgi_spec.rb - 2014-03-09 10:47
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
  describe 'master::perlfcgi', :type => :class do

    let(:facts) do {
        :osfamily  => $os_family[os],
        :operatingsystem => os,
    } end 

    context "supports operating system: #{os}" do
      context "provides master::perlfcgi class which" do
        it { should contain_class('master::perlfcgi') }
        context "default params" do
          it { should contain_file('/usr/sbin/perl-fcgi.pl') }
        end
        context "test dir param" do
          let :params do {
              :testdir => '/srv/www',
          } end
          it { should contain_file('/srv/www/perl-fcgi-test.pl')}
        end
      end
    end
  end
}
