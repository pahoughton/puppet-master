# master-service-gitolite_spec.rb - 2014-03-08 14:25
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# FIXME - best test would be ssh git@HOST info from admin account
#
require 'spec_helper'

os_family = {
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}

basedir = '/srv/gitolite'
tobject = 'master::service::gitolite'
['Fedora','CentOS'].each { |os|
  describe tobject, :type => :class do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
    }
    context "supports facts #{tfacts}" do
      let(:facts) do tfacts end
      tparams = {
        :admin_key => 'paul.pub',
        :basedir   => basedir,
      }
      context "params #{tparams}" do
        let :params do tparams end
        it { should contain_class(tobject) }
        it {
          should contain_file("#{basedir}/.gitolite/hooks/common/post-receive").
          with('ensure' => 'file',
               'mode'   => '0755',)
        }
      end
    end
  end
}
