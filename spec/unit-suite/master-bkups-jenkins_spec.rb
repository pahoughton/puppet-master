# master-bkups-jenkins_spec.rb - 2014-03-25 02:30
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

os_family = {
  'Fedora' => 'redhat',
  'CentOS' => 'redhat',
  'Ubuntu' => 'debian',
}

tobject = 'master::bkups::jenkins'
thost   = 'thostname'
['Fedora','CentOS','Ubuntu',].each { |os|
  describe tobject, :type => :define do
    tfacts = {
      :osfamily               => os_family[os],
      :operatingsystem        => os,
    }
    let(:facts) do tfacts end
    context "supports facts #{tfacts}" do
      let (:title) { thost }
      context "params default" do
        it { should contain_master__bkups__jenkins(thost) }
        it { should contain_bacula__dir__fileset("#{thost}-jenkins") }
        it { should contain_bacula__dir__job("#{thost}-jenkins") }
      end
    end
  end
}
