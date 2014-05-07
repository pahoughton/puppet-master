# master-mirror-yum_spec.rb - 2014-05-06 04:58
#
# Copyright (c) 2014 Paul Houghton <paul_houghton@cable.comcast.com>
#
require 'spec_helper'

supported = {
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

mhost = 'tgandalf'

classes = {
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
      'undef' => ['epel'],
      '6' => [],
      '7' => [],
    },
  },
}
files = {
  'RedHat' => {
    'undef' => {
      'undef' => ['/etc/pki/rpm-gpg/rpmfusion-free.key',
                  '/etc/pki/rpm-gpg/rpmfusion-nonfree.key',
                  "/etc/yum.repos.d/#{mhost}-rpmfusion.repo",
                  '/etc/yum.repos.d/rpmfusion-free.repo',
                  '/etc/yum.repos.d/rpmfusion-free-updates-released.repo',
                  '/etc/yum.repos.d/rpmfusion-nonfree.repo',
                  '/etc/yum.repos.d/rpmfusion-nonfree-updates-released.repo',
                 ],
    },
    'Fedora' => {
      'undef' => ['/etc/yum.repos.d/fedora.repo',
                  '/etc/yum.repos.d/fedora-updates.repo',
                  '/etc/yum.repos.d/fedora-updates-testing.repo',
                  "/etc/yum.repos.d/#{mhost}-Fedora.repo",
                 ],
      '19' => [],
      '20' => [],
      '21' => [],
    },
    'CentOS' => {
      'undef' => [ '/etc/yum.repos.d/CentOS-Base.repo',
                   '/etc/yum.repos.d/CentOS-Debuginfo.repo',
                   '/etc/yum.repos.d/CentOS-Media.repo',
                   '/etc/yum.repos.d/CentOS-Vault.repo',
                 ],
      '6' => [],
      '7' => [],
    },
  },
}

tobject = 'master::mirror::yum'

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
        }
        let(:facts) do tfacts end
        context "supports facts #{tfacts}" do
          #print "p:#{fam}:#{os}:#{rel}:#{packages[fam][os][rel]}\n"
          classes[fam][os][rel].each { |cls|
            it { should contain_class(cls) }
          }
          files[fam][os][rel].each { |fn|
            it { should contain_file(fn) }
          }
        end
      end
    }
  }
}
