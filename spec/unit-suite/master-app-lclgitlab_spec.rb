# master-nginx-lclgitlab_spec.rb - 2014-03-23 07:31
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

tobject = 'master::app::lclgitlab'

classes = {
  'Debian' => {
    'undef' => {
      'undef' => ['gitlab',],
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
      'undef' => ['gitlab',],
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
  'Debian' => {
    'undef' => {
      'undef' => ['redis-server',
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
      'undef' => ['redis',
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

services = {
  'Debian' => {
    'undef' => {
      'undef' => ['redis-server'],
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
      'undef' => ['redis'],
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

supported = {
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
          services[fam][os][rel].each { |svc|
            it { should contain_service(svc) }
          }
        end
      end
    }
  }
}
