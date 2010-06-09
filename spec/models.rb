class TestParent < ActiveRecord::Base
  has_many :test_children
  has_many :other_test_children,
    :class_name => 'TestChild', :foreign_key => 'other_test_parent_id'

  acts_as_audited_collection_parent :for => :test_children
  acts_as_audited_collection_parent :for => :other_test_children
end

class TestChild < ActiveRecord::Base
  belongs_to :test_parent
  belongs_to :other_test_parent,
    :class_name => 'TestParent'

  has_many :test_grandchildren

  acts_as_audited_collection :parent => :test_parent
  acts_as_audited_collection :parent => :other_test_parent,
      :name => :other_test_children,
      :track_modifications => true

  acts_as_audited_collection_parent :for => :test_grandchildren
end

class TestGrandchild < ActiveRecord::Base
  belongs_to :test_child

  acts_as_audited_collection :parent => :test_child, :cascade => true
end
