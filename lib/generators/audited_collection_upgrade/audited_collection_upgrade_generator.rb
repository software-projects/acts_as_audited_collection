# Released under the MIT license. See the LICENSE file for details

class AuditedCollectionMigrationGenerator < Rails::Generator::NamedBase
  include Rails::Generators::Migration
  attr_reader :from_version

  argument :from, :type => :string, :default => '', :banner => 'VERSION'

  def main_screen_turn_on
    self.from_version = from.split '.'
    migration_template 'migration.rb', "db/migrate"
  end
end
