require 'rake'
require 'rake/testtask'
require 'rdoc/task'
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

desc 'Generate documentation for the acts_as_audited_collection plugin.'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ActsAsAuditedCollection'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/*_spec.rb'
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'acts_as_audited_collection'
    gem.summary = 'Extends ActiveRecord to allow auditing of associations'
    gem.description = 'Adds auditing capabilities to ActiveRecord associations, in a similar fashion to acts_as_audited.'
    gem.files = Dir[
      '[a-zA-Z]*',
      'generators/**/*',
      'lib/**/*',
      'rails/**/*',
      'spec/**/*'
    ]
    gem.authors = ['Shaun Mangelsdorf']
    gem.version = '0.4.1'
  end
rescue LoadError
  puts "Jeweler could not be sourced"
end
