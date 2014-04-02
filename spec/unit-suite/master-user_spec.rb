# user_spec.rb - 2014-03-08 08:39
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'


$os_family = {
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}
['Fedora','CentOS','Ubuntu'].each { |os|
  describe 'master::user', :type => :define do

    let(:facts) do {
        :osfamily  => $os_family[os],
        :operatingsystem => os,
    } end

    context "supports operating system: #{os}" do
      context "provides master::user define which" do
        username = 'paul'
        context "defaults" do
          let(:title) { username }
          it { should contain_group(username) }
          it { should contain_user(username) }
          it { should contain_file("/home/#{username}/.gitconfig").
            with( 'ensure'  => 'file',
                  'owner'   => username,
                  'group'   => username,
                  'mode'    => '0644',
                  'content' => /email/, )
          }
        end

        context "given rsa key" do
          let(:title) {username}

          let :params do {
              :rsa  => "puppet::///master/tester.id_rsa",
              :home => "/home/#{username}",
            } end
          it { should contain_file("/home/#{username}").
            with( 'ensure' => 'directory', )
          }
          it { should contain_file("/home/#{username}/.ssh/id_rsa") }
          it { should contain_file("/home/#{username}/.ssh/id_rsa.pub") }
          it { should contain_file("/home/#{username}/.ssh/authorized_keys") }
        end
        context "libvirt authorization" do
          let(:facts) do {
              :osfamily  => 'redhat',
              :operatingsystem => 'Fedora',
            } end
          let(:title) {username}
          let :params do {
              :libvirt => true,
            } end
          it "define libvirt policy for #{username}" do
            should contain_policykit__localauthority("#{username}-libvirt-management")
          end
        end
      end
    end
  end
}
