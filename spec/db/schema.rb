# Released under the MIT license. See the LICENSE file for details

ActiveRecord::Schema.define(:version => 0) do
  create_table :test_parents, :force => true do |t|
    t.string :name
    t.timestamps
  end

  create_table :test_children, :force => true do |t|
    t.string :name
    t.string :description
    t.references :test_parent
    t.references :other_test_parent
    t.references :test_parent_with_only
    t.references :test_parent_with_except
    t.timestamps
  end

  create_table :test_grandchildren, :force => true do |t|
    t.string :name
    t.references :test_child
    t.timestamps
  end

  create_table :test_great_grandchildren, :force => true do |t|
    t.string :name
    t.references :test_grandchild
    t.timestamps
  end

  create_table :test_soft_delete_grandchildren, :force => true do |t|
    t.string :name
    t.boolean :deleted
    t.references :test_child
    t.timestamps
  end

  create_table :collection_audits, :force => true do |t|
    t.references :parent_record, :polymorphic => {}
    t.references :child_record, :polymorphic => {}
    t.references :user, :polymorphic => {}
    t.references :child_audit
    t.string :action
    t.string :association
    t.datetime :created_at
  end
end
