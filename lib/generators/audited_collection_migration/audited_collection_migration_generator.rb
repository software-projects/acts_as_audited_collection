# Released under the MIT license. See the LICENSE file for details

class AuditedCollectionMigrationGenerator < Rails::Generators::NamedBase
  def manifest
    migration_template 'migration.rb', "db/migrate"
  end
end
