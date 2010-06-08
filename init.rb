require 'acts_as_audited_collection'

ActiveRecord::Base.send :include, ActiveRecord::Acts::AuditedCollection
