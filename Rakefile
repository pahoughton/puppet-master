# Rakefile - 2014-03-07 01:44
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
require 'rake'
require 'rspec/core/rake_task'

require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.disable_80chars
PuppetLint.configuration.disable_class_parameter_defaults
PuppetLint.configuration.ignore_paths = FileList['**/fixtures/modules/**/**']

desc "Test prep with librarian-puppet"
task :unittest_prep do
 sh "librarian-puppet install --path=spec/fixtures/modules/"
end

desc "Unit tests"
RSpec::Core::RakeTask.new(:unittest) do |t|
  t.pattern = 'spec/unit/**/*_spec.rb'
end

desc "Unit tests"
RSpec::Core::RakeTask.new(:unittest_doc) do |t|
  t.rspec_opts = ['--format=d']
  t.pattern = 'spec/unit/**/*_spec.rb'
end

desc "Unit-suite tests w/o doc"
RSpec::Core::RakeTask.new(:unittest_nodoc) do |t|
  t.pattern = 'spec/unit-suite/**/*_spec.rb'
end

desc "Unit-suite tests w/ doc"
RSpec::Core::RakeTask.new(:unittest_suite) do |t|
  t.rspec_opts = ['--format=d','--out=unitsuite-results.txt']
  t.pattern = 'spec/unit-suite/**/*_spec.rb'
end
