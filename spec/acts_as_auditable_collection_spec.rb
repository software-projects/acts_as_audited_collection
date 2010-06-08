require File.dirname(__FILE__) + '/spec_helper'

describe 'Acts as auditable collection plugin' do
  it 'can be included in an ActiveRecord model' do
    class A < ActiveRecord::Base
      self
    end.should respond_to :acts_as_auditable_collection
  end

  it 'requires a parent to be specified' do
    lambda {
      class B < ActiveRecord::Base
        acts_as_auditable_collection
      end
    }.should raise_error ActiveRecord::ConfigurationError
  end

  it 'infers the collection name correctly from the class' do
    class Person < ActiveRecord::Base
      belongs_to :employer

      acts_as_auditable_collection :parent => :employer

      auditable_collections
    end.should have_key :people
  end

  it 'allows the auditable collection through a belongs_to relationship' do
    class Person < ActiveRecord::Base
      belongs_to :test

      acts_as_auditable_collection :parent => :test
    end
  end

  it 'refuses the auditable collection through a has_one relationship' do
    lambda {
      class Person < ActiveRecord::Base
        has_one :test

        acts_as_auditable_collection :parent => :test
      end
    }.should raise_error ActiveRecord::ConfigurationError
  end
end
