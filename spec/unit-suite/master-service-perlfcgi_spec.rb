# master-perlfcgi_spec.rb - 2014-03-09 10:47
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#

require 'spec_helper'

username = 'paul'

os_family = {
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}

tobject = 'master::service::perlfcgi'
['Fedora','CentOS','Ubuntu'].each { |os|
  describe tobject, :type => :class do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
    }
    context "supports facts #{tfacts}" do
      let(:facts) do tfacts end
      it { should contain_class(tobject) }
      context "params default" do
        it { should contain_file('/usr/sbin/perl-fcgi.pl') }
      end
      tparams = {
        :testdir => '/srv/www',
      }
      context "params #{tparams}" do
        let :params do tparams end
        it { should contain_file('/srv/www/perl-fcgi-test.pl')}
      end
    end
  end
}
