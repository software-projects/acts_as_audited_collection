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
    lambda {
      p = TestParent.create :name => 'test parent'
      c = p.test_children.create :name => 'test child'
    }.should change(CollectionAudit, :count).by(1)
  end

  it 'skips auditing on object creation when no relationships are defined' do
    lambda {
      p = TestParent.create :name => 'test parent'
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
end
