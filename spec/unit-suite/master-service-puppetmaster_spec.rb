# master-puppetmaster_spec.rb - 2014-03-09 10:15
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

$os_family = {
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}
# todo - support other operating systems.
tobject = 'master::puppetmaster'
['Fedora'].each { |os|
  describe tobject, :type => :class do

    let(:facts) do {
        :osfamily  => $os_family[os],
        :operatingsystem => os,
    } end

    context "supports operating system: #{os}" do
      context "provides #{tobject} class which" do
        it { should contain_class(tobject) }
        context "defaults" do
          it { should contain_package('puppet-server') }
          it { should contain_service('puppetmaster') }
          it { should contain_package('librarian-puppet') }
          # Fixme - fedora
          it { should contain_exec('open port 8140 for puppet') }
          it { should contain_file('/root/scripts/puppet.apply.bash') }
          it { should contain_file('/root/scripts/puppet.update.bash') }
        end
      end
    end
  end
}
