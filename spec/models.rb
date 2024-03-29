# Released under the MIT license. See the LICENSE file for details

class TestParent < ActiveRecord::Base
  has_many :test_children
  has_many :other_test_children,
    :class_name => 'TestChild', :foreign_key => 'other_test_parent_id'
  has_many :test_children_with_only,
    :class_name => 'TestChild', :foreign_key => 'test_parent_with_only_id'
  has_many :test_children_with_except,
    :class_name => 'TestChild', :foreign_key => 'test_parent_with_except_id'

  acts_as_audited_collection_parent :for => :test_children
  acts_as_audited_collection_parent :for => :other_test_children
  acts_as_audited_collection_parent :for => :test_children_with_only
  acts_as_audited_collection_parent :for => :test_children_with_except
end

class TestFakeParent < ActiveRecord::Base
  has_many :test_children

  acts_as_audited_collection_parent :for => :test_children
end

class TestChild < ActiveRecord::Base
  belongs_to :test_parent
  belongs_to :test_fake_parent
  belongs_to :other_test_parent,
    :class_name => 'TestParent'
  belongs_to :test_parent_with_only,
    :class_name => 'TestParent'
  belongs_to :test_parent_with_except,
    :class_name => 'TestParent'

  has_many :test_grandchildren
  has_many :test_soft_delete_grandchildren

  acts_as_audited_collection :parent => :test_parent
  acts_as_audited_collection :parent => :test_fake_parent
  acts_as_audited_collection :parent => :other_test_parent,
      :name => :other_test_children,
      :track_modifications => true
  acts_as_audited_collection :parent => :test_parent_with_only,
      :name => :test_children_with_only,
      :track_modifications => true,
      :only => :name
  acts_as_audited_collection :parent => :test_parent_with_except,
      :name => :test_children_with_except,
      :track_modifications => true,
      :except => :name

  acts_as_audited_collection_parent :for => :test_grandchildren
  acts_as_audited_collection_parent :for => :test_soft_delete_grandchildren
end

class TestGrandchild < ActiveRecord::Base
  belongs_to :test_child

  has_many :test_great_grandchildren

  acts_as_audited_collection :parent => :test_child, :cascade => true,
      :track_modifications => true

  acts_as_audited_collection_parent :for => :test_great_grandchildren
end

class TestGreatGrandchild < ActiveRecord::Base
  belongs_to :test_grandchild

  acts_as_audited_collection :parent => :test_grandchild, :cascade => true
end

class TestSoftDeleteGrandchild < ActiveRecord::Base
  belongs_to :test_child

  acts_as_audited_collection :parent => :test_child, :soft_delete => {:deleted => true},
      :cascade => true, :track_modifications => true
end
