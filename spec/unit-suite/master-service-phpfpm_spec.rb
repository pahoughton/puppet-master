# phpfpm_spec.rb - 2014-03-10 09:39
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

username = 'paul'

os_family = {
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}
tobject = 'master::service::phpfpm'
['Fedora','CentOS','Ubuntu'].each { |os|
  describe tobject, :type => :class do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
    }
    context "supports facts #{tfacts}" do
      let(:facts) do tfacts end
      [tobject,
       'php::cli',
       'php::fpm::daemon',
      ].each { |cls|
        it { should contain_class(cls) }
      }
      it { should contain_php__ini('/etc/php.ini') }
      it { should contain_php__fpm__conf('www')
          .with( 'listen' => 'localhost:9000',
                 'user'   => 'nginx',
                 'group'  => 'nginx', )
      }
    end
  end
}
