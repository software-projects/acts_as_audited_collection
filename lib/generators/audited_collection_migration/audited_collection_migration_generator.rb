# Released under the MIT license. See the LICENSE file for details

require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record/migration'

class AuditedCollectionMigrationGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  extend ActiveRecord::Generators::Migration

  source_root File.join(File.dirname(__FILE__), 'templates')

  def manifest
    migration_template 'migration.rb', "db/migrate/#{file_name}"
  end
end
