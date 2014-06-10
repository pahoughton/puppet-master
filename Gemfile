# Gemfile - 2014-05-10 03:03
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
source 'https://rubygems.org'

group :development, :test do
  #gem 'bundler'
  #gem 'builder']
  gem 'rake'
  gem 'rspec-puppet'
  gem 'librarian-puppet'
  gem 'puppet-lint'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
