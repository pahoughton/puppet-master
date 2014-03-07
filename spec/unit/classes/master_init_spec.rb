# master_init_spec.rb - 2014-03-07 02:10
#
# Copyright (CC) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'spec_helper'

describe 'master' do

  it 'provides the master class' do
    should contain_file('stuff')
  end

end
