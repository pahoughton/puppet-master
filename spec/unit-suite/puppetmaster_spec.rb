# puppetmaster_spec.rb - 2014-03-09 10:15
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#

$os_family = {
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}
['Fedora','CentOS','Ubuntu'].each { |os|
  describe 'master::puppetmaster', :type => :class do
    let(:facts) do {
        :osfamily  => $os_family[os],
        :operatingsystem => os,
    } end 
    context "supports operating system: #{os}" do
      context "provides master::puppetmaster class which" do
        it { should contain_class('master::puppetmaster') }
        it { should contain_package('puppet-server') }
        it { should contain_service('puppetmaster') }
        it { should contain_package('librarian-puppet') }
        # FIXME - firewall open puppet port.
        it { should contain_file('/root/scripts/puppet.apply.bash') }
        it { should contain_file('/root/scripts/puppet.update.bash') }
      end
    end
  end
}
