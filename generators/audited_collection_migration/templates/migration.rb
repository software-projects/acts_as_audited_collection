class <%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table :collection_audits, :force => true do |t|
      t.references :parent_record, :polymorphic => {}
      t.references :child_record, :polymorphic => {}
      t.references :user, :polymorphic => {}
      t.references :child_audit
      t.string :action
      t.string :association
      t.datetime :created_at

      t.index [:parent_record_id, :parent_record_type], :name => 'parent_record_index'
      t.index [:child_record_id, :child_record_type], :name => 'child_record_index'
      t.index [:user_id, :user_type], :name => 'user_index'
    end
  end

  def self.down
    drop_table :collection_audits
  end
end
