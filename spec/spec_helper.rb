# Released under the MIT license. See the LICENSE file for details

Bundler.require

require 'logger'

plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")
# Railties aren't loaded in this environment
ActiveRecord::Base.send :extend, ActiveRecord::Acts::AuditedCollection::ClassMethods

databases = YAML::load(IO.read(plugin_spec_dir + "/db/database.yml"))
ActiveRecord::Base.establish_connection(databases[ENV["DB"] || "sqlite3"])
load(File.join(plugin_spec_dir, "db", "schema.rb"))

require File.join(File.dirname(__FILE__), '..', 'init.rb')

require 'models.rb'
