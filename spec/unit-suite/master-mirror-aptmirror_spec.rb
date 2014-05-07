# master-mirror-aptmirror_spec.rb - 2014-05-06 05:39
#
# Copyright (c) 2014 Paul Houghton <paul_houghton@cable.comcast.com>
#
# basenode_spec.rb - 2014-03-08 10:00
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

supported = {
  'Debian' => {
    'Ubuntu' => ['undef',
                 '13',
                 '14',
                ],
  },
}

lsbname = {
  'Debian' => {
    'Ubuntu' => {
      'undef' => 'precise',
      '12' => 'precise',
      '13' => 'saucy',
      '14' => 'trusty',
    },
  },
}

classes = {
  'Debian' => {
    'Ubuntu' => {
      'undef' => ['apt'],
      '13' => [],
      '14' => [],
    },
  },
}
tobject = 'master::mirror::aptmirror'

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
          it { should contain_apt__source('tgandalf') }
        end
      end
    }
  }
}
