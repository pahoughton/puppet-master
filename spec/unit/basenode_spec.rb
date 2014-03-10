# basenode_spec.rb - 2014-03-08 10:00
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

# these are the files for existing repos that the mirror provides.
$repo_files = {
  'Fedora' => ['/etc/yum.repos.d/fedora.repo',
              '/etc/yum.repos.d/fedora-updates.repo',
              '/etc/yum.repos.d/fedora-updates-testing.repo',
              '/etc/yum.repos.d/rpmfusion-free.repo',
              '/etc/yum.repos.d/rpmfusion-free-updates-released.repo',
              '/etc/yum.repos.d/rpmfusion-nonfree.repo',
              '/etc/yum.repos.d/rpmfusion-nonfree-updates-released.repo',],
  'CentOS' => ['/etc/yum.repos.d/CentOS-Base.repo',
              '/etc/yum.repos.d/CentOS-Debuginfo.repo',
              '/etc/yum.repos.d/CentOS-Media.repo',
              '/etc/yum.repos.d/CentOS-Vault.repo',
              '/etc/yum.repos.d/epel.repo',],
  'Ubuntu' => [''],
}

$common_pkgs = [
  'xterm',
  'emacs',
  'git',
  'subversion',
  'cvs',
  'rcs',
  'automake',
  'sysstat',
  'lsof',
  'nmap',
  'iftop',
  'lynx',
  'zfs-fuse',
  'unar',
  'xorg-x11-apps',
]
   
                
$os_pkgs = {
  'Fedora' => ['redhat-lsb',],
  'CentOS' => ['redhat-lsb',],
  'Ubuntu' => [],
}

$os_family = {
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}
$os_release = {
  'Fedora' => '20',
  'CentOS' => '6',
  'Ubuntu' => '13',
}

$mirror='gandalf'
  
['Fedora','CentOS','Ubuntu'].each { |os|
  describe 'master::basenode', :type => :class do
    let(:facts) do {
        :osfamily               => $os_family[os],
        :operatingsystem        => os,
        :operatingsystemrelease => $os_release[os],
        :os_maj_version         => $os_release[os],
      } end 
    context "supports operating system: #{os}" do
      context "default params" do
        context "provides master::basenode class which" do
          it { should contain_class('master::basenode') }
          if $os_family[os] == 'redhat'
            it { should contain_class('epel') }
            it { should contain_class('rpmfusion') }
          end
          if os == 'CentOS'
            it { should contain_yumrepo('pjku') }
          end
        end
      end
      context "given repo_mirror param" do
        let :params do {
            :repo_mirror => $mirror,
        } end
        context "provides master::basenode class which" do
          it { should contain_class('master::basenode') }

          if $os_family[os] == 'redhat'
            context "disables existing repos provided by mirror: #{$mirror}" do
              $repo_files[os].each {|rfile|
                it "ensures #{rfile} absent" do 
                  should contain_file(rfile).with(
                    'ensure' => 'absent',
                  )
                end
              }
            end
            it "installs repo mirror file for yum for #{os}" do
              should contain_file("/etc/yum.repos.d/#{$mirror}-#{os}.repo").
                with_content(/#{$mirror}/)
              should contain_file("/etc/yum.repos.d/#{$mirror}-rpmfusion.repo").
                with_content(/#{$mirror}/)
            end
          end
        end
      end
# FIXME param dependent!
#        it { should contain_ssh_authorized_key("root-paul") }
      context "param independent features" do
        context "installs base packages" do
          $common_pkgs.each{|pkg|
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
        end
        it { should contain_service('zfs-fuse').
          with( 'ensure' => 'running',
                'enable' => true, )
        }
        it { should contain_file('/root/scripts/pagent').
          with( 'ensure' => 'file',
                'mode'   => '+x',)
        }
        # this is redhat
        $sudo_grp = 'wheel'
        it { should contain_sudo__conf("group: #{$sudo_grp}") }
        it { should contain_exec('update info dir') }
      end
    end
  end
} # end os loop 
