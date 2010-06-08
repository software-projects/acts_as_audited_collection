require 'acts_as_auditable_collection'

ActiveRecord::Base.send :include, ActiveRecord::Acts::AuditableCollection
