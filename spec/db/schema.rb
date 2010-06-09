ActiveRecord::Schema.define(:version => 0) do
  create_table :test_parents, :force => true do |t|
    t.string :name
    t.timestamps
  end

  create_table :test_children, :force => true do |t|
    t.string :name
    t.references :test_parent
    t.timestamps
  end
end
