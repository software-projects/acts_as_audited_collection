require 'rake'
require 'spec/rake/spectask'

require 'rubygems'
require 'rake/gempackagetask'

PKG_FILES = FileList[
  '[a-zA-Z]*',
  'generators/**/*',
  'lib/**/*',
  'rails/**/*',
  'spec/**/*'
]

spec = Gem::Specification.new do |s|
  s.name = 'acts_as_audited_collection'
  s.version = '0.2'
  s.author = 'Shaun Mangelsdorf'
  s.email = 's.mangelsdorf@gmail.com'
  s.homepage = 'http://smangelsdorf.github.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Extends ActiveRecord to allow auditing of associations'
  s.files = PKG_FILES.to_a
  s.require_path = 'lib'
  s.has_rdoc = false
  s.extra_rdoc_files = ['README']
  s.rubyforge_project = 'auditcollection'
  s.description = <<EOF
Adds auditing capabilities to ActiveRecord associations, in a similar fashion to acts_as_audited.
EOF
end

desc 'Default: run specs.'
task :default => :spec

desc 'Run the specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc 'Turn this plugin into a gem.'
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end
