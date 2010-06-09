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
      belongs_to :parent

      acts_as_audited_collection :parent => :parent

      audited_collections
    end.should have_key :people
  end

  it 'allows the audited collection through a belongs_to relationship' do
    class Person < ActiveRecord::Base
      belongs_to :parent

      acts_as_audited_collection :parent => :parent
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
end
