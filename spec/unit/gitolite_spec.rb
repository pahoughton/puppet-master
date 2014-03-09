# gitolite_spec.rb - 2014-03-08 14:25
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
# FIXME - best test would be ssh git@HOST info from admin account
#
require 'spec_helper'

$test_object = 'master::gitolite'
$basedir = '/srv/gitolite'
['Fedora','CentOS'].each { |os|
  describe $test_object, :type => :class do
    let(:facts) do {
        :osfamily  => 'redhat',
        :operatingsystem => os,
      } end 
    let :params do {
        :admin_key => 'paul.pub',
        :basedir   => $basedir,
      } end
    context "supports operating system: #{os}" do
      context "provides master::#{$test_object} class which" do
        it { should contain_class($test_object) }
      end
      it "installs default post-receive hook" do
        should contain_file("#{$basedir}/.gitolite/hooks/common/post-receive").with({
          'ensure' => 'file',
        })
      end
    end
  end
}
