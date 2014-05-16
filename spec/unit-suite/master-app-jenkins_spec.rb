# master-app-jenkins_spec.rb - 2014-03-09 11:01
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

tobject = 'master::app::jenkins'

packages = {
  'Debian' => {
    'undef' => {
      'undef' => ['jenkins'],
    },
    'Ubuntu' => {
      'undef' => [],
      '13' => ['jenkins'],
      '14' => ['jenkins'],
    },
    'Debian' => {
      'undef' => [],
      '7' => [],
    },
  },
  'RedHat' => {
    'undef' => {
      'undef' => ['jenkins'],
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
  'Debian' => {
    'undef' => {
      'undef' => ['/etc/default/jenkins'],
    },
    'Ubuntu' => {
      'undef' => [],
      '13' => [],
      '14' => ['/etc/default/jenkins'],
    },
    'Debian' => {
      'undef' => [],
      '7' => [],
    },
  },
  'RedHat' => {
    'undef' => {
      'undef' => ['/etc/sysconfig/jenkins'],
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
services = {
  'Debian' => {
    'undef' => {
      'undef' => ['jenkins'],
    },
    'Ubuntu' => {
      'undef' => [],
      '13' => ['jenkins'],
      '14' => ['jenkins'],
    },
    'Debian' => {
      'undef' => [],
      '7' => [],
    },
  },
  'RedHat' => {
    'undef' => {
      'undef' => ['jenkins'],
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

lsbname = {
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

justone = {
  'Debian' => {
    'Ubuntu' => ['14',
                ],
  }
}

justone.keys.each { |fam|
  osfam = justone[fam]
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
          packages[fam][os][rel].each { |pkg|
            it { should contain_package(pkg) }
          }
          files[fam][os][rel].each { |fn|
            it { should contain_file(fn) }
          }
          services[fam][os][rel].each { |svc|
            it { should contain_service(svc) }
          }
          it { should contain_apt__source('jenkins') }
          tparams = {
            :vhost => 'localhost',
          }
          context "supports params #{tparams}" do
            let :params do tparams end
            it { should contain_nginx__resource__location('jenkins') }
          end
        end
      end
    }
  }
}

supported = {
  'Debian' => {
    'Debian' => ['7',
                ],
    'Ubuntu' => ['13',
                 '14',
                ],
  },
  'RedHat' => {
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
          packages[fam][os][rel].each { |pkg|
            it { should contain_package(pkg) }
          }
          files[fam][os][rel].each { |fn|
            it { should contain_file(fn) }
          }
          services[fam][os][rel].each { |svc|
            it { should contain_service(svc) }
          }
        end
      end
    }
  }
}
