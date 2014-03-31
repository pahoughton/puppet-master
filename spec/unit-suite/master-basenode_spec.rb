# basenode_spec.rb - 2014-03-08 10:00
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

os_lsbdist = {
  'Ubuntu' => 'ubuntu',
}
os_lsbname = {
  'Ubuntu' => 'precise',
}

# these are the files for existing repos that the mirror provides.
repo_files = {
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

common_pkgs = ['xterm',
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
               'zfs-fuse',]
os_pkgs = {
  'Fedora' => ['redhat-lsb',
               'policycoreutils-python',
               'bind-utils',
               'unar',
               'xorg-x11-apps',
              ],
  'CentOS' => ['redhat-lsb',
               'policycoreutils-python',
               'man',
               'bind-utils',
               'xorg-x11-apps',
              ],
  'Ubuntu' => ['unar',
               'policycoreutils',
               'bind9utils',
               'x11-apps',
              ],
}
os_family = {
  'Fedora' => 'RedHat',
  'CentOS' => 'RedHat',
  'Ubuntu' => 'debian',
}
os_rel = {
  'Fedora' => '20',
  'CentOS' => '6',
  'Ubuntu' => '13',
}

mirror  = 'tgandalf'
tobject = 'master::basenode'
['Fedora','CentOS','Ubuntu'].each { |os|
  describe tobject, :type => :class do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
      :operatingsystemrelease => os_rel[os],
      :os_maj_version         => os_rel[os],
      # todo apt module
      :lsbdistid              => os_lsbdist[os],
      :lsbdistcodename        => os_lsbname[os],
    }
    let(:facts) do tfacts end
    context "supports facts #{tfacts}" do
      let(:facts) do tfacts end
      context "param independent features" do
        [tobject,
         'gcc',].each{ |cls|
          it { should contain_class(cls) }
        }
        let :params do tparams end
        if os_family[os] == 'redhat'
          context "disables existing repos provided by mirror: #{$mirror}" do
            repo_files[os].each {|rfile|
              it "ensures #{rfile} absent" do
                should contain_file(rfile).with(
                  'ensure' => 'absent',
                )
              end
            }
          end
          it "installs repo mirror file for yum for #{os}" do
            should contain_file("/etc/yum.repos.d/#{mirror}-#{os}.repo").
              with_content(/#{$mirror}/)
            should contain_file("/etc/yum.repos.d/#{mirror}-rpmfusion.repo").
              with_content(/#{$mirror}/)
          end
        end
      end
      context "osfamily independent features for #{os}-#{os_family[os]}" do
        it { should contain_sudo__conf("group: sudo") }
      end
      context "param independent features" do
        common_pkgs.each{|pkg|
          it { should contain_package(pkg) }
        }
        os_pkgs[os].each{|pkg|
          it { should contain_package(pkg) }
        }
        it { should contain_service('zfs-fuse').
          with( 'ensure' => 'running',
                'enable' => true, )
        }
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

['Fedora'].each { |os|
  describe tobject, :type => :class do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
      :operatingsystemrelease => os_rel[os],
      :os_maj_version         => os_rel[os],
    }
    let(:facts) do tfacts end
    context "supports RedHat facts #{tfacts}" do
      context "params default" do
        it { should contain_class('epel') }
        it { should contain_class('rpmfusion') }
      end
      tparams = {
        :repo_mirror => mirror,
      }
      context "params #{tparams}" do
        let :params do tparams end
        context "disables existing repos provided by mirror: #{$mirror}" do
          repo_files[os].each {|rfile|
            it { should contain_file(rfile).
              with( 'ensure' => 'absent',)
            }
          }
        end
        it { should contain_file("/etc/yum.repos.d/#{mirror}-#{os}.repo").
          with_content(/#{$mirror}/)
        }
        it { should contain_file("/etc/yum.repos.d/#{mirror}-rpmfusion.repo").
          with_content(/#{$mirror}/)
        }
      end
      it {
        should contain_exec('firewall-cmd --zone=public --add-service=https')
      }
      it { should contain_exec('update info dir') }
    end
  end
}
['Ubuntu'].each { |os|
  describe tobject, :type => :class do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
      :operatingsystemrelease => os_rel[os],
      :os_maj_version         => os_rel[os],
      # todo apt module
      :lsbdistid              => os_lsbdist[os],
      :lsbdistcodename        => os_lsbname[os],
    }
    let(:facts) do tfacts end
    context "supports Ubuntu facts #{tfacts}" do
      context "params default - no tasks" do
      end
      tparams = {
        :repo_mirror => mirror,
      }
      context "params #{tparams}" do
        let :params do tparams end
        # fixme - wip
        # it { should contain_class('apt').
        #   with( 'purge_sources_list' => true )
        # }
        it { should contain_apt__source( "#{mirror}_saucy" ).
          with( 'location' => "http://#{mirror}/mirrors/apt/ubuntu/" )
        }
        # todo apt module broken
        # it { should contain_apt__source( "#{mirror}-saucy-updates" ).
        #   with( 'location' => "http://#{mirror}/mirrors" )
        # }
      end
      it { should contain_firewall('010 accept http(s)(80,443)') }
    end
  end
}

['CentOS'].each { |os|
  describe tobject, :type => :class do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
      :operatingsystemrelease => os_rel[os],
      :os_maj_version         => os_rel[os],
    }
    let(:facts) do tfacts end
    context "supports CentOS facts #{tfacts}" do
      context "params default" do
        it { should contain_yumrepo('pjku') }
      end
      it { should contain_firewall('010 accept http(s)(80,443)') }
    end
  end
}
