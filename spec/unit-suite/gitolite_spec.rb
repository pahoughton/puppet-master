# gitolite_spec.rb - 2014-03-08 14:25
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# FIXME - best test would be ssh git@HOST info from admin account
#
require 'spec_helper'

$basedir = '/srv/gitolite'
['Fedora','CentOS'].each { |os|

  describe 'master::gitolite', :type => :class do
    let(:facts) do {
        :osfamily  => 'redhat',
        :operatingsystem => os,
      } end 
    let :params do {
        :admin_key => 'paul.pub',
        :basedir   => $basedir,
      } end
    context "supports operating system: #{os}" do
      context "provides master::gitolite class which" do
        it { should contain_class('master::gitolite') }
      
        it "installs default post-receive hook" do
          should contain_file("#{$basedir}/.gitolite/hooks/common/post-receive").with({
            'ensure' => 'file',
            'mode'   => '0755',

          })
        end
      end
    end
  end
}
