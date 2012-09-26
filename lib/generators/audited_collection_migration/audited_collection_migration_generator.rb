# Released under the MIT license. See the LICENSE file for details

class AuditedCollectionMigrationGenerator < Rails::Generators::NamedBase
  source_root File.join(File.dirname(__FILE__), 'templates')

  def manifest
    migration_template 'migration.rb', "db/migrate/#{file_name}"
  end
end
