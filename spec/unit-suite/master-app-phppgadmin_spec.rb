# master-app-phppgadmin_spec.rb - 2014-04-05 16:59
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
tappdir = '/srv/www/phppgadmin'
tcfgfn  = "#{tappdir}/conf/config.inc.php"

tobject = 'master::app::phppgadmin'
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
      it { should contain_class(tobject) }
      [tobject,
      ].each { |cls|
        it { should contain_class(cls) }
      }
      it { should contain_vcsrepo(tappdir) }
      it { should contain_file(tcfgfn).
        with( 'owner' => 'nginx',
              'group' => 'nginx',)
      }
      ['pgsql',
      ].each { |pmod|
        it { should contain_php__module(pmod) }
      }
    end
  end
}
