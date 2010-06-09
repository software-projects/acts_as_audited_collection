class TestParent < ActiveRecord::Base
  has_many :test_children
end

class TestChild < ActiveRecord::Base
  belongs_to :test_parent
  acts_as_audited_collection :parent => :test_parent
end
