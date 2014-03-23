# master-nginx-mygitlab_spec.rb - 2014-03-23 07:31
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

os_family = {
  'Fedora' => 'RedHat',
  'CentOS' => 'RedHat',
  'Ubuntu' => 'debian',
}
os_release = {
  'Fedora' => '20',
  'CentOS' => '6',
  'Ubuntu' => '13',
}

tobject = 'master::nginx::mygitlab'
['Fedora','CentOS','Ubuntu',].each { |os|
  describe tobject, :type => :class do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
      :operatingsystemrelease => os_release[os],
      :os_maj_version         => os_release[os],
    }
    let(:facts) do tfacts end
    context "supports facts #{tfacts}" do
      #it { should compile } #?- fail: expected that the catalogue would include
      it { should contain_class(tobject) }
      it { should contain_class('gitlab').
        with( 'git_create_user' => false,
              'git_home'        => '/srv/tgitolite',
              'git_email'       => 'tester@nowhere.com',
              'git_comment'     => 'gitolite and gitlab user',
              'gitlab_dbtype'   => 'pgsql',
              'gitlab_dbhost'   => 'tpostgres',
              'gitlab_dbname'   => 'gitlab',
              'gitlab_dbuser'   => 'gitlab',
              'gitlab_dbpwd'    => 'tpsqlglab', )
      }
   end
  end
}
