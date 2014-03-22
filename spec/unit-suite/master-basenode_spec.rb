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
              '/etc/yum.repos.d/CentOS-Vault.repo',],
  'Ubuntu' => [''],
}

$common_pkgs = ['xterm',
                'emacs',
                'make',
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
                'xorg-x11-apps',]



$os_pkgs = {
  'Fedora' => ['redhat-lsb',
               'policycoreutils-python',
               'bind-utils',
               'unar',
              ],
  'CentOS' => ['redhat-lsb',
               'policycoreutils-python',
               'man',
               'bind-utils',
              ],
  'Ubuntu' => ['unar',
               'policycoreutils',
               'bind9utils',
              ],
}

$os_family = {
  'Fedora' => 'RedHat',
  'CentOS' => 'RedHat',
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
      context "osfamily dependent features for #{os}-#{$os_family[os]}" do
        it { should contain_sudo__conf("group: sudo") }
      end
      context "param independent features" do
        context "installs base packages" do
          $common_pkgs.each{|pkg|
            it { should contain_package(pkg)
                .with( 'ensure' => 'installed', )
            }
          }
          $os_pkgs[os].each{|pkg|
            it { should contain_package(pkg)
                .with( 'ensure' => 'installed', )
            }
          }
        end
        it { should contain_service('zfs-fuse').
          with( 'ensure' => 'running',
                'enable' => true, )
        }
        # ugg - test for one iteration of the loop
        if os.casecmp('fedora' )
          it { should
            contain_exec('firewall-cmd --zone=public --add-service=https')
          }
        else
          it { should contain_firewall('010 accept http(s)(80,443)') }
        end
        it { should contain_file('/root/scripts/pagent').
          with( 'ensure' => 'file',
                'mode'   => '+x',)
        }
        it { should contain_exec('update info dir') }
      end

      bacdir_host='testbacdirhost'
      context "param bacula_director => '#{bacdir_host}'" do
        let :params do {
            :bacula_director => bacdir_host,
        } end
        it { should contain_class('bacula::fd').
          with('dir_host' => bacdir_host)
        }
      end

      context 'param auth_key_[type,value&name] set' do
        ktype='ssh-rsa'
        kval='test-key-value'
        kname='tester@nowhere.com'
        let :params do {
            :auth_key_type  => ktype,
            :auth_key_value => kval,
            :auth_key_name => kname,
        } end
        it { should contain_ssh_authorized_key("root:#{kname}").
          with('ensure' => 'present',
               'user'   => 'root',
               'name'   => kname, )
        }
      end
    end
  end
} # end os loop
