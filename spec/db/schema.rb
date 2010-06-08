ActiveRecord::Schema.define(:version => 0) do
  create_table :parents, :force => true do |t|
    t.string :name
    t.timestamps
  end

  create_table :children, :force => true do |t|
    t.string :name
    t.references :parent
    t.timestamps
  end
end
