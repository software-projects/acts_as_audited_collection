#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rake'
require 'rake/testtask'
require 'rspec/core/rake_task'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the acts_as_audited_collection plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/*_spec.rb'
end
