# basenode_spec.rb - 2014-03-08 10:00
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

supported = {
  'undef' => {
    'undef' => ['undef',
                ],
  },
  'Debian' => {
    'undef' => ['undef',
               ],
    'Debian' => ['undef',
                 '7',
                ],
    'Ubuntu' => ['undef',
                 '13',
                 '14',
                ],
  },
  'RedHat' => {
    'undef' => ['undef'
               ],
    'Fedora' => ['undef',
                '19',
                '20',
                '21',
                ],
    'CentOS' => ['undef',
                '6',
                '7',
                ],
  },
}

lsbname = {
  'undef' => {
    'undef' =>  {},
  },
  'Debian' => {
    'undef' => {},
    'Debian' => {
      '7' => 'wheezy',
    },
    'Ubuntu' => {
      'undef' => 'precise',
      '12'    => 'precise',
      '13'    => 'saucy',
      '14'    => 'trusty',
    },
  },
  'RedHat' => {
    'undef' => {},
    'Fedora' => {
      '19' => '19',
      '20' => '20',
      '21' => '21',
    },
    'CentOS' => {
      '6' => '6',
      '7' => '7',
    },
  },
}

classes = {
  'undef' => {
    'undef' => {
      'undef' => ['gcc'],
    },
  },
  'Debian' => {
    'undef' => {
      'undef' => [],
    },
    'Ubuntu' => {
      'undef' => [],
      '13' => [],
      '14' => [],
    },
    'Debian' => {
      'undef' => [],
      '7' => [],
    },
  },
  'RedHat' => {
    'undef' => {
      'undef' => [],
      },
    'Fedora' => {
      'undef' => [],
      '19' => [],
      '20' => [],
      '21' => [],
    },
    'CentOS' => {
      'undef' => [],
      '6' => [],
      '7' => [],
    },
  },
}

packages = {
  'undef' => {
    'undef' => {
      'undef' => ['xterm',
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
                  'unar',
                  'zfs-fuse',
                 ],
    },
  },
  'Debian' => {
    'undef' => {
      'undef' => ['bind9utils',
                  'policycoreutils',
                  'x11-apps',
                  ],
    },
    'Ubuntu' => {
      'undef' => [],
      '13' => [],
      '14' => [],
    },
    'Debian' => {
      'undef' => [],
      '7' => [],
    },
  },
  'RedHat' => {
    'undef' => {
      'undef' => ['bind-utils',
                  'policycoreutils-python',
                  'redhat-lsb',
                  'xorg-x11-apps',
                  ],
    },
    'Fedora' => {
      'undef' => [],
      '19' => [],
      '20' => [],
      '21' => [],
    },
    'CentOS' => {
      'undef' => [],
      '6' => [],
      '7' => [],
    },
  },
}

files = {
  'undef' => {
    'undef' => {
      'undef' => ['/root/scripts/pagent',
                  '/etc/profile.d/custom.sh',],
    },
  },
  'Debian' => {
    'undef' => {
      'undef' => [],
    },
    'Ubuntu' => {
      'undef' => [],
      '13' => [],
      '14' => [],
    },
    'Debian' => {
      'undef' => [],
      '7' => [],
    },
  },
  'RedHat' => {
    'undef' => {
      'undef' => [],
      },
    'Fedora' => {
      'undef' => [],
      '19' => [],
      '20' => [],
      '21' => [],
    },
    'CentOS' => {
      'undef' => [],
      '6' => [],
      '7' => [],
    },
  },
}



tobject = 'master::basenode'

supported.keys.each { |fam|
  osfam = supported[fam]
  osfam.keys.each { |os|
    osfam[os].each { |rel|
      describe tobject, :type => :class do
        tfacts = {
          :osfamily               => fam,
          :operatingsystem        => os,
          :operatingsystemrelease => rel,
          :os_maj_version         => rel,
          :lsbdistid              => os,
          :lsbdistcodename        => lsbname[fam][os][rel],
        }
        let(:facts) do tfacts end
        context "supports facts #{tfacts}" do
          #print "p:#{fam}:#{os}:#{rel}:#{packages[fam][os][rel]}\n"
          classes[fam][os][rel].each { |cls|
            it { should contain_class(cls) }
          }
          packages[fam][os][rel].each { |pkg|
            it { should contain_package(pkg) }
          }
          files[fam][os][rel].each { |fn|
            it { should contain_file(fn) }
          }
          tparams = {
            :mirror_host => 'mirror',
          }
          context "supports params #{tparams}" do
            let :params do tparams end
            if fam == 'Fedora'
              it { should contain_class('master::mirror::yum') }
            end
            if fam == 'Debian'
              it { should contain_class('master::mirror::aptmirror') }
            end
          end
        end
      end
    }
  }
}

anyoneos = {
  'undef' => {
    'undef' => ['undef',
                ],
  },
}

anyoneos.keys.each { |fam|
  osfam = anyoneos[fam]
  osfam.keys.each { |os|
    osfam[os].each { |rel|
      describe tobject, :type => :class do
        tfacts = {
          :osfamily               => fam,
          :operatingsystem        => os,
          :operatingsystemrelease => rel,
          :os_maj_version         => rel,
          :lsbdistid              => os,
          :lsbdistcodename        => lsbname[fam][os][rel]
        }
        let(:facts) do tfacts end
        context "supports facts #{tfacts}" do
          it { should contain_group('puppet') }
          it { should contain_service('zfs-fuse') }
          it { should contain_exec( 'update info dir') }
        end
      end
    }
  }
}

notfedora = {
  'undef' => {
    'undef' => ['undef',
                ],
  },
  'Debian' => {
    'undef' => ['undef',
               ],
    'Debian' => ['undef',
                 '7',
                ],
    'Ubuntu' => ['undef',
                 '13',
                 '14',
                ],
  },
  'RedHat' => {
    'undef' => ['undef'
               ],
    'CentOS' => ['undef',
                '6',
                '7',
                ],
  },
}

notfedora.keys.each { |fam|
  osfam = notfedora[fam]
  osfam.keys.each { |os|
    osfam[os].each { |rel|
      describe tobject, :type => :class do
        tfacts = {
          :osfamily               => fam,
          :operatingsystem        => os,
          :operatingsystemrelease => rel,
          :os_maj_version         => rel,
          :lsbdistid              => os,
          :lsbdistcodename        => lsbname[fam][os][rel]
        }
        let(:facts) do tfacts end
        context "supports facts #{tfacts}" do
          it { should contain_firewall('010 accept http(s)(80,443)') }
        end
      end
    }
  }
}

# ['Fedora','CentOS','Ubuntu','Debian'].each { |os|
#   describe tobject, :type => :class do
#     tfacts = {
#       :osfamily               => os_family[os],
#       :operatingsystem        => os,
#       :operatingsystemrelease => os_rel[os],
#       :os_maj_version         => os_rel[os],
#       # todo apt module
#       :lsbdistid              => os_lsbdist[os],
#       :lsbdistcodename        => os_lsbname[os],
#     }
#     context "supports facts #{tfacts}" do
#       let(:facts) do tfacts end
#       context "param independent features" do
#         [tobject,
#          'gcc',].each{ |cls|
#           it { should contain_class(cls) }
#         }
#       end
#       context "osfamily independent features for #{os}-#{os_family[os]}" do
#         it { should contain_sudo__conf("group: sudo") }
#       end
#       context "param independent features" do
#         common_pkgs.each{|pkg|
#           it { should contain_package(pkg) }
#         }
#         if ofam_pkgs[os_family[os]]
#           ofam_pkgs[os_family[os]].each{|pkg|
#             it { should contain_package(pkg) }
#           }
#         end
#         if os_pkgs[os]
#           os_pkgs[os].each{|pkg|
#             it { should contain_package(pkg) }
#           }
#         end
#         it { should contain_service('zfs-fuse').
#           with( 'ensure' => 'running',
#                 'enable' => true, )
#         }
#         it { should contain_file('/root/scripts/pagent').
#           with( 'ensure' => 'file',
#                 'mode'   => '+x',)
#         }
#         it { should contain_exec('update info dir') }
#       end
#       bacdir_host='testbacdirhost'
#       tparams = {
#         :bacula_director => bacdir_host
#       }
#       context "param #{tparams}" do
#         # fixme
#         #let :params do tparams end
#         let (:params) do { :bacula_director => bacdir_host } end
#         it { should contain_class('bacula::fd').
#           with('dir_host' => bacdir_host)
#         }
#       end
#       ktype='ssh-rsa'
#       kval='test-key-value'
#       kname='tester@nowhere.com'
#       tparams = {
#         :auth_key_type  => ktype,
#         :auth_key_value => kval,
#         :auth_key_name  => kname,
#       }
#       context 'param auth_key_[type,value&name] set' do
#         let :params do tparams end
#         it { should contain_ssh_authorized_key("root:#{kname}").
#           with('ensure' => 'present',
#                'user'   => 'root',
#                'name'   => kname, )
#         }
#       end
#     end
#   end
# } # end os loop

# ['Fedora'].each { |os|
#   describe tobject, :type => :class do
#     tfacts = {
#       :osfamily               => os_family[os],
#       :operatingsystem        => os,
#       :operatingsystemrelease => os_rel[os],
#       :os_maj_version         => os_rel[os],
#     }
#     let(:facts) do tfacts end
#     context "supports RedHat facts #{tfacts}" do
#       context "params default" do
#         it { should contain_class('epel') }
#         it { should contain_class('rpmfusion') }
#       end
#       tparams = {
#         :repo_mirror => mirror,
#       }
#       context "params #{tparams}" do
#         let :params do tparams end
#         context "disables existing repos provided by mirror: #{mirror}" do
#           repo_files[os].each {|rfile|
#             it { should contain_file(rfile).
#               with( 'ensure' => 'absent',)
#             }
#           }
#         end
#         it { should contain_file("#{rpmfusion_gpg_prefix}-free-fedora-20") }
#         it { should contain_file("#{rpmfusion_gpg_prefix}-nonfree-fedora-20") }

#         it { should contain_file("/etc/yum.repos.d/#{mirror}-#{os}.repo").
#           with_content(/#{$mirror}/)
#         }
#         it { should contain_file("/etc/yum.repos.d/#{mirror}-rpmfusion.repo").
#           with_content(/#{$mirror}/)
#         }
#       end
#       it {
#         should contain_exec('firewall-cmd --zone=public --add-service=https')
#       }
#       it { should contain_exec('update info dir') }
#     end
#   end
# }
# ['Ubuntu'].each { |os|
#   describe tobject, :type => :class do
#     tfacts = {
#       :osfamily               => os_family[os],
#       :operatingsystem        => os,
#       :operatingsystemrelease => os_rel[os],
#       :os_maj_version         => os_rel[os],
#       # todo apt module
#       :lsbdistid              => os_lsbdist[os],
#       :lsbdistcodename        => os_lsbname[os],
#     }
#     let(:facts) do tfacts end
#     context "supports Ubuntu facts #{tfacts}" do
#       context "params default - no tasks" do
#       end
#       tparams = {
#         :repo_mirror => mirror,
#       }
#       context "params #{tparams}" do
#         let :params do tparams end
#         # fixme - wip
#         # it { should contain_class('apt').
#         #   with( 'purge_sources_list' => true )
#         # }
#         it { should contain_apt__source( "#{mirror}_saucy" ).
#           with( 'location' => "http://#{mirror}/mirrors/apt/ubuntu/" )
#         }
#         # todo apt module broken
#         # it { should contain_apt__source( "#{mirror}-saucy-updates" ).
#         #   with( 'location' => "http://#{mirror}/mirrors" )
#         # }
#       end
#       it { should contain_firewall('010 accept http(s)(80,443)') }
#     end
#   end
# }

# ['CentOS'].each { |os|
#   describe tobject, :type => :class do
#     tfacts = {
#       :osfamily               => os_family[os],
#       :operatingsystem        => os,
#       :operatingsystemrelease => os_rel[os],
#       :os_maj_version         => os_rel[os],
#     }
#     let(:facts) do tfacts end
#     context "supports CentOS facts #{tfacts}" do
#       context "params default" do
#         it { should contain_yumrepo('pjku') }
#       end
#       it { should contain_firewall('010 accept http(s)(80,443)') }
#     end
#   end
# }
