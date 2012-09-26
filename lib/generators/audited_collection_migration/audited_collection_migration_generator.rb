# Released under the MIT license. See the LICENSE file for details

class AuditedCollectionMigrationGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.migration_template 'migration.rb', "db/migrate"
    end
  end
end
