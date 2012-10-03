# -*- encoding: utf-8 -*-
require File.expand_path('../lib/acts_as_audited_collection/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Shaun Mangelsdorf"]
  gem.email         = ["s.mangelsdorf@gmail.com"]
  gem.description   = %q{Adds auditing capabilities to ActiveRecord associations, in a similar fashion to acts_as_audited.}
  gem.summary       = %q{Extends ActiveRecord to allow auditing of associations}
  gem.homepage      = "https://github.com/smangelsdorf/acts_as_audited_collection"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "acts_as_audited_collection"
  gem.require_paths = ["lib"]
  gem.version       = ActsAsAuditedCollection::VERSION

  gem.add_development_dependency 'ruby-debug'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rails', '~>3.2'
  gem.add_development_dependency 'sqlite3'
end
