# 2015-10-10 (cc) <paul4hough@gmail.com>
#
require 'spec_helper'

tobject = 'master::sysstat'
ttype = :class

supported = {
  'undef' => {
    'undef' => ['undef',
               ],
  },
}

packages = {
  'undef' => {
    'undef' => {
      'undef' => ['sysstat',
                  'bzip2',],
    },
  },
}

files = {
  'undef' => {
    'undef' => {
      'undef' => ['/etc/sysconfig/sysstat',
                  ],
    },
  },
}


supported.keys.each { |fam|
  osfam = supported[fam]
  osfam.keys.each { |os|
    osfam[os].each { |rel|
      describe tobject, :type => ttype do
        tfacts = {
          :osfamily               => fam,
          :operatingsystem        => os,
          :operatingsystemrelease => rel,
          :os_maj_version         => rel,
          :lsbdistid              => os,
        }
        let(:facts) do tfacts end
        context "supports facts #{tfacts}" do
          #print "p:#{fam}:#{os}:#{rel}:#{packages[fam][os][rel]}\n"
          packages[fam][os][rel].each { |pkg|
            it { should contain_package(pkg) }
          }
          files[fam][os][rel].each { |pkg|
            it { should contain_file(pkg) }
          }
        end
      end
    }
  }
}
