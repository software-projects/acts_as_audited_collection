class <%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table :collection_audits, :force => true do |t|
      t.references :parent_record, :polymorphic => {}
      t.references :child_record, :polymorphic => {}
      t.references :user, :polymorphic => {}
      t.string :username
      t.string :action
      t.datetime :created_at
    end
  end

  def self.down
    remove_table :collection_audits
  end
end
