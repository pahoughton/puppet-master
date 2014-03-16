# devel_spec.rb - 2014-03-09 09:40
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
$osfamily_pkgs = {
  'redhat' => [ 'yum-utils',
                'man-pages',
                'emacs-el',
                'postgresql-devel',
                'ruby-devel',],
  'debian' => [ 'libpq-devel',
                'mysql-client',
                'emacs24-el',
                'ruby-full',],
}
$os_pkgs = {
  'Fedora' => ['mariadb-devel'],
  'CentOS' => ['mysql-devel',],
  'Ubuntu' => [],
}
$os_family = {
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}
  
$common_pkgs = ['git-svn',
                'flex',
                'meld',
                'rspec-core',
                'puppet-gem',
                'rspec-mocks',
                'rspec-expectations',]

['Fedora','CentOS','Ubuntu'].each { |os|
  describe 'master::devel', :type => :class do
    let(:facts) do {
        :osfamily        => $os_family[os],
        :operatingsystem => os,
        :kernel          => 'Linux',
    } end 
    context "supports operating system: #{os}" do
      context "provides master::devel class which" do
        it { should contain_class('master::devel') }
        context "installs devel packages" do

          $osfamily_pkgs[$os_family[os]].each{|pkg|
            it "ensure #{pkg} is installed" do
              should contain_package(pkg).with(
                'ensure' => 'installed',
              )
            end
          }          
          $os_pkgs[os].each{|pkg|
            it "ensure #{pkg} is installed" do
              should contain_package(pkg).with(
                'ensure' => 'installed',
              )
            end
          }
          $common_pkgs.each{|pkg|
            it "ensure #{pkg} is installed" do
              should contain_package(pkg).with(
                'ensure' => 'installed',
              )
            end
          }
        end
        it { should contain_class('python') }
      end
    end
  end
}
