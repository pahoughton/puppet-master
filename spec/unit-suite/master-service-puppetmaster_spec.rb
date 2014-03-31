# master-puppetmaster_spec.rb - 2014-03-09 10:15
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

os_family = {
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}
# todo - support other operating systems.
tobject = 'master::service::puppetmaster'
['Fedora'].each { |os|
  describe tobject, :type => :class do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
    }
    context "supports facts #{tfacts}" do
      let(:facts) do tfacts end
      context "params default" do
        it { should contain_class(tobject) }
        it { should contain_package('puppet-server') }
        it { should contain_service('puppetmaster') }
        it { should contain_package('librarian-puppet') }
        # Fixme - fedora
        it { should contain_exec('open port 8140 for puppet') }
      end
    end
  end
}
