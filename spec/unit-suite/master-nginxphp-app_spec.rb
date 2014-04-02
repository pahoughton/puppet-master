# master-nginxphp-app_spec.rb - 2014-03-25 03:33
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

os_family = {
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}

tobject = 'master::nginxphp::app'
tapp    = 'tcal'
['Fedora','CentOS','Ubuntu',].each { |os|
  describe tobject, :type => :define do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
    }
    let(:facts) do tfacts end
    context "supports facts #{tfacts}" do
      let (:title) { tapp }
      context "params default" do
        it { should contain_master__nginxphp__app(tapp) }
        it { should contain_nginx__resource__location("#{tapp}_php") }
      end
      tparams = {
        :db_host => 'thost',
        :db_name => 'tcaldb',
        :db_user => 'tcal',
        :db_pass => 'tcalp',
      }
      # fixme
      # context "with params #{tparams}" do
      #   let :params do tparams end;
      #   it { should contain_mysql__db('tcaldb').
      #     with( 'host'     => 'thost',
      #           'user'     => 'tcal',
      #           'password' => 'tcalp',)
      #   }
      # end
      tparams = {
        :db_driver => 'postgresql',
        :db_host   => 'thost',
        :db_name   => 'tcaldb',
        :db_user   => 'tcal',
        :db_pass   => 'tcalp',
      }
      # fixme
      # context "with params #{tparams}" do
      #   let :params do tparams end;
      #   it { should contain_postgresql__server__db('tcaldb').
      #     with( 'host'     => 'thost',
      #           'user'     => 'tcal',
      #           'password' => 'tcalp',)
      #   }
      # end
    end
  end
}
