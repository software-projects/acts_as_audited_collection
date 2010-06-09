class TestParent < ActiveRecord::Base
  has_many :test_children
  has_many :other_test_children,
    :class_name => 'TestChild', :foreign_key => 'other_test_parent_id'
end

class TestChild < ActiveRecord::Base
  belongs_to :test_parent
  belongs_to :other_test_parent,
    :class_name => 'TestParent'

  acts_as_audited_collection :parent => :test_parent
  acts_as_audited_collection :parent => :other_test_parent, :name => :other_test_children
end
