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

  it 'audits an object modification when a relation is altered' do
    c = TestChild.create :name => 'test child'
    p = TestParent.create :name => 'test parent'

    lambda {
      c.test_parent = p
      c.save
    }.should change(CollectionAudit, :count).by(1)

    CollectionAudit.last.child_record.should == c
    CollectionAudit.last.parent_record.should == p
    CollectionAudit.last.action.should == 'add'
  end
end
