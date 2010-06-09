ActiveRecord::Schema.define(:version => 0) do
  create_table :test_parents, :force => true do |t|
    t.string :name
    t.timestamps
  end

  create_table :test_children, :force => true do |t|
    t.string :name
    t.references :test_parent
    t.references :other_test_parent
    t.timestamps
  end

  create_table :test_grandchildren, :force => true do |t|
    t.string :name
    t.references :test_child
    t.timestamps
  end

  create_table :collection_audits, :force => true do |t|
    t.references :parent_record, :polymorphic => {}
    t.references :child_record, :polymorphic => {}
    t.references :user, :polymorphic => {}
    t.string :action
    t.string :association
    t.datetime :created_at
  end
end
