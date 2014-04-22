# master-php-composer_spec.rb - 2014-04-11 14:01
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
# defined by fixtures/hiera/common.json
tcurl   = 'curl -sS https://getcomposer.org/installer | php'

tobject = 'master::php::composer'
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
      # FIXME
      # it { should compile } - fail: expected that the catalogue would include
      [tobject,
      ].each { |cls|
        it { should contain_class(cls) }
      }
      it { should contain_exec(tcurl).
        with( 'creates' => '/root/composer.phar' )
      }
      it { should contain_file('/usr/local/bin/composer') }
    end
  end
}
