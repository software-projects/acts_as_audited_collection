# Released under the MIT license. See the LICENSE file for details

require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record/migration'

class AuditedCollectionUpgradeGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  extend ActiveRecord::Generators::Migration
  attr_accessor :from_version

  source_root File.join(File.dirname(__FILE__), 'templates')

  argument :from, :type => :string, :default => '', :banner => 'VERSION'

  def main_screen_turn_on
    self.from_version = from.split '.'
    migration_template 'migration.rb', "db/migrate/#{file_name}"
  end
end
