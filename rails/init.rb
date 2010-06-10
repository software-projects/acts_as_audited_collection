# Released under the MIT license. See the LICENSE file for details

require 'acts_as_audited_collection'

ActiveRecord::Base.send :include, ActiveRecord::Acts::AuditedCollection
