require 'acts_as_audited_collection'
require 'rails'

module ActsAsAuditedCollection
  class Railtie < Rails::Railtie
    initializer 'acts_as_audited_collection.active_record_hooks' do
      ActiveRecord::Base.send :extend, ActiveRecord::Acts::AuditedCollection::ClassMethods
    end
  end
end
