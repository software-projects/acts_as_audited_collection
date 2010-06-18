# Released under the MIT license. See the LICENSE file for details

require File.dirname(__FILE__) + '/spec_helper'

describe 'Acts as audited collection plugin' do
  it 'can be included in an ActiveRecord model' do
    class A < ActiveRecord::Base
      self
    end.should respond_to :acts_as_audited_collection
  end

  it 'requires a parent to be specified' do
    lambda {
      class B < ActiveRecord::Base
        acts_as_audited_collection
      end
    }.should raise_error ActiveRecord::ConfigurationError
  end

  it 'infers the collection name correctly from the class' do
    class Person < ActiveRecord::Base
      belongs_to :test_parent

      acts_as_audited_collection :parent => :test_parent

      audited_collections
    end.should have_key :people
  end

  it 'allows the audited collection through a belongs_to relationship' do
    class Person < ActiveRecord::Base
      belongs_to :test_parent

      acts_as_audited_collection :parent => :test_parent
    end
  end

  it 'refuses the audited collection through a has_one relationship' do
    lambda {
      class Person < ActiveRecord::Base
        has_one :test

        acts_as_audited_collection :parent => :test
      end
    }.should raise_error ActiveRecord::ConfigurationError
  end

  it 'refuses an audited collection parent where no child relation is specified' do
    lambda {
      class Person < ActiveRecord::Base
        acts_as_audited_collection_parent
      end
    }.should raise_error ActiveRecord::ConfigurationError
  end

  it 'refuses an audited collection parent through a belongs_to relationship' do
    lambda {
      class Person < ActiveRecord::Base
        belongs_to :test

        acts_as_audited_collection_parent :for => :test
      end
    }.should raise_error ActiveRecord::ConfigurationError
  end

  it 'allows an audited collection parent through a has_many relationship' do
    class Person < ActiveRecord::Base
      has_many :tests

      acts_as_audited_collection_parent :for => :tests
    end
  end

  it 'configures an audited collection for cascading when required' do
    class Person < ActiveRecord::Base
      belongs_to :test_parent

      acts_as_audited_collection :parent => :test_parent, :cascade => true
    end

    Person.audited_collections.should have_key :people
    Person.audited_collections[:people].should have_key :cascade
    Person.audited_collections[:people][:cascade].should be_true
  end

  it 'configures an audited collection to track modificiations when required' do
    class Person < ActiveRecord::Base
      belongs_to :test_parent

      acts_as_audited_collection :parent => :test_parent, :track_modifications => true
    end

    Person.audited_collections.should have_key :people
    Person.audited_collections[:people].should have_key :track_modifications
    Person.audited_collections[:people][:track_modifications].should be_true
  end

  it 'audits an object creation when relationships are defined' do
    p = TestParent.create :name => 'test parent'
    c = nil
    lambda {
      c = p.test_children.create :name => 'test child'
    }.should change(CollectionAudit, :count).by(1)

    CollectionAudit.last.child_record.should == c
    CollectionAudit.last.parent_record.should == p
    CollectionAudit.last.action.should == 'add'
  end

  it 'skips auditing on object creation when no relationships are defined' do
    p = TestParent.create :name => 'test parent'
    lambda {
      c = TestChild.create :name => 'test child'
    }.should_not change(CollectionAudit, :count)
  end

  it 'audits an object modification when a relation is created' do
    c = TestChild.create :name => 'test child'
    p = TestParent.create :name => 'test parent'

    lambda {
      c.test_parent = p
      c.save!
    }.should change(CollectionAudit, :count).by(1)

    CollectionAudit.last.child_record.should == c
    CollectionAudit.last.parent_record.should == p
    CollectionAudit.last.action.should == 'add'
  end

  it 'skips auditing on object modification when no relationships are altered' do
    c = TestChild.create :name => 'test child'
    p = TestParent.create :name => 'test parent'

    lambda {
      c.name = 'new name'
      c.save!
    }.should_not change(CollectionAudit, :count)
  end

  it 'audits an object modification when a relationship is removed' do
    p = TestParent.create :name => 'test parent'
    c = p.test_children.create :name => 'test child'

    lambda {
      c.test_parent = nil
      c.save!
    }.should change(CollectionAudit, :count).by(1)

    CollectionAudit.last.child_record.should == c
    CollectionAudit.last.parent_record.should == p
    CollectionAudit.last.action.should == 'remove'
  end

  it 'audits an object deletion when a relationship exists' do
    p = TestParent.create :name => 'test parent'
    c = p.test_children.create :name => 'test child'

    lambda {
      c.destroy.should be_true
    }.should change(CollectionAudit, :count).by(1)

    # child_record will be nil, because the record has been deleted.
    CollectionAudit.last.child_record_id.should == c.id
    CollectionAudit.last.parent_record.should == p
    CollectionAudit.last.action.should == 'remove'
  end

  it 'skips auditing an object deletion when no relationships exist' do
    c = TestChild.create :name => 'test child'

    lambda {
      c.destroy.should be_true
    }.should_not change(CollectionAudit, :count)
  end

  it 'saves the collection name with the audit entry' do
    p = TestParent.create :name => 'test parent'
    c = p.test_children.create :name => 'test child'
    CollectionAudit.last.association.should == 'test_children'
  end

  it 'makes the collection history available through the parent class' do
    p = TestParent.create :name => 'test parent'
    c = p.test_children.create :name => 'test child'

    p.test_children_audits.should include CollectionAudit.last
  end

  it 'correctly audits a secondary collection' do
    p = TestParent.create :name => 'test parent'
    c = nil
    lambda {
      c = p.other_test_children.create :name => 'test child'
    }.should change(CollectionAudit, :count).by(1)

    # Basic sanity checking, to make sure the model stays valid
    p.other_test_children.should include c
    p.test_children.should be_empty
    c.other_test_parent.should == p
    c.test_parent.should be_nil

    p.test_children_audits.should be_empty
    p.other_test_children_audits.length.should == 1

    p.other_test_children_audits.last.child_record.should == c
    p.other_test_children_audits.last.parent_record.should == p
    p.other_test_children_audits.last.action.should == 'add'
    p.other_test_children_audits.last.association.should == 'other_test_children'
  end

  it 'correctly audits when a parent is reassociated through a secondary collection' do
    p = TestParent.create :name => 'test parent'
    c = p.test_children.create :name => 'test child'
    lambda {
      c.test_parent = nil
      c.other_test_parent = p
      c.save!
    }.should change(CollectionAudit, :count).by(2)

    # One from the initial creation
    p.test_children_audits.length.should == 2
    p.test_children_audits.should be_all { |a| a.child_record == c }
    p.test_children_audits.first.action.should == 'add'
    p.test_children_audits.last.action.should == 'remove'
    p.other_test_children_audits.length.should == 1
    p.other_test_children_audits.should be_all { |a| a.child_record == c && a.action == 'add' }
  end

  it 'correctly audits when a child is assigned to a new parent' do
    p1 = TestParent.create :name => 'test parent'
    c = p1.test_children.create :name => 'test child'
    p2 = TestParent.create :name => 'another parent'

    lambda {
      c.test_parent = p2
      c.save!
    }.should change(CollectionAudit, :count).by(2)

    # One from the initial creation
    p1.test_children_audits.length.should == 2
    p1.test_children_audits.should be_all { |a| a.child_record == c }
    p1.test_children_audits.first.action.should == 'add'
    p1.test_children_audits.last.action.should == 'remove'
    p2.test_children_audits.length.should == 1
    p2.test_children_audits.should be_all { |a| a.child_record == c && a.action == 'add' }
  end

  it 'disables collection auditing for a block passed to the without_collection_audit method' do
    p = TestParent.create :name => 'test parent'
    c = nil
    lambda {
      result = TestChild.without_collection_audit do
        c = p.test_children.create :name => 'test child'
      end

      # Make sure we get the right return value
      result.should == c
    }.should_not change(CollectionAudit, :count)
  end

  it 'enables collection auditing after completion of a block passed to the without_collection_audit method' do
    p = TestParent.create :name => 'test parent'
    TestChild.without_collection_audit do
      p.test_children.create :name => 'test child'
    end
    lambda {
      p.test_children.create :name => 'another child'
    }.should change(CollectionAudit, :count).by(1)
  end

  it 'tracks modifications through an auditing collection with modification tracking enabled' do
    p = TestParent.create :name => 'test parent'
    c = p.other_test_children.create :name => 'test child'

    lambda {
      c.name = 'new name'
      c.save!
    }.should change(CollectionAudit, :count).by(1)

    CollectionAudit.last.child_record.should == c
    CollectionAudit.last.parent_record.should == p
    CollectionAudit.last.action.should == 'modify'
  end

  it 'tracks modifications to attributes listed in :only' do
    p = TestParent.create :name => 'test parent'
    c = p.test_children_with_only.create :name => 'test child'

    lambda {
      c.name = 'new name'
      c.save!
    }.should change(CollectionAudit, :count).by(1)

    CollectionAudit.last.child_record.should == c
    CollectionAudit.last.parent_record.should == p
    CollectionAudit.last.action.should == 'modify'
  end

  it 'ignores modifications to attributes not listed in :only' do
    p = TestParent.create :name => 'test parent'
    c = p.test_children_with_only.create :name => 'test child'

    lambda {
      c.description = 'new description'
      c.save!
    }.should_not change(CollectionAudit, :count)
  end

  it 'ignores modifications to attributes listed in :except' do
    p = TestParent.create :name => 'test parent'
    c = p.test_children_with_except.create :name => 'test child'

    lambda {
      c.name = 'new name'
      c.save!
    }.should_not change(CollectionAudit, :count)
  end

  it 'tracks modifications to attributes not listed in :except' do
    p = TestParent.create :name => 'test parent'
    c = p.test_children_with_except.create :name => 'test child'

    lambda {
      c.description = 'new name'
      c.save!
    }.should change(CollectionAudit, :count).by(1)

    CollectionAudit.last.child_record.should == c
    CollectionAudit.last.parent_record.should == p
    CollectionAudit.last.action.should == 'modify'
  end

  it 'tracks grandchild modifications through a cascading auditing collection' do
    p = TestParent.create :name => 'test parent'
    # other_test_children has track_modifications enabled
    c = p.other_test_children.create :name => 'test child'
    g = nil
    lambda {
      g = c.test_grandchildren.create :name => 'test grandchild'
    }.should change(CollectionAudit, :count).by(2)

    audits = CollectionAudit.find :all, :order => 'id desc', :limit => 2
    # First the grandchild would have been logged ..
    audits[1].child_record.should == g
    audits[1].parent_record.should == c
    audits[1].action.should == 'add'
    # .. then the child would have been logged.
    audits[0].child_record.should == c
    audits[0].parent_record.should == p
    audits[0].action.should == 'modify'
  end

  it 'tracks a grandchild being reassociated with a different child' do
    p = TestParent.create :name => 'test parent'
    # other_test_children has track_modifications enabled
    c1 = p.other_test_children.create :name => 'test child'
    c2 = p.other_test_children.create :name => 'another child'
    g = c1.test_grandchildren.create :name => 'test grandchild'

    lambda {
      g.update_attributes :test_child => c2
    }.should change(CollectionAudit, :count).by(4)

    audits = CollectionAudit.find :all, :order => 'id desc', :limit => 4

    # First the grandchild removal would have been logged ..
    audits[3].child_record.should == g
    audits[3].parent_record.should == c1
    audits[3].action.should == 'remove'
    # .. then the child 1 modification would have been logged ..
    audits[2].child_record.should == c1
    audits[2].parent_record.should == p
    audits[2].action.should == 'modify'
    # .. then the grandchild addition would have been logged ..
    audits[1].child_record.should == g
    audits[1].parent_record.should == c2
    audits[1].action.should == 'add'
    # .. then the child 2 modification would have been logged.
    audits[0].child_record.should == c2
    audits[0].parent_record.should == p
    audits[0].action.should == 'modify'
  end

  it 'tracks great-grandchild modifications through a cascading auditing collection' do
    p = TestParent.create :name => 'test parent'
    c = p.other_test_children.create :name => 'test child'
    g = c.test_grandchildren.create :name => 'test grandchild'
    gg = nil

    lambda {
      gg = g.test_great_grandchildren.create :name => 'test great-grandchild'
    }.should change(CollectionAudit, :count).by(3)

    audits = CollectionAudit.find :all, :order => 'id desc', :limit => 3
    # First the great-grandchild would have been logged ..
    audits[2].child_record.should == gg
    audits[2].parent_record.should == g
    audits[2].action.should == 'add'
    # .. then the grandchild would have been logged ..
    audits[1].child_record.should == g
    audits[1].parent_record.should == c
    audits[1].action.should == 'modify'
    # .. then the child would have been logged.
    audits[0].child_record.should == c
    audits[0].parent_record.should == p
    audits[0].action.should == 'modify'
  end

  it 'tracks the child audit of a cascading audit' do
    p = TestParent.create :name => 'test parent'
    # other_test_children has track_modifications enabled
    c = p.other_test_children.create :name => 'test child'
    g = c.test_grandchildren.create :name => 'test grandchild'

    pa = p.other_test_children_audits.last
    ca = c.test_grandchildren_audits.last
    pa.child_audit.should == ca
    ca.parent_audits.should == [pa]
  end
end
