# Released under the MIT license. See the LICENSE file for details
require 'active_record'

class CollectionAudit < ActiveRecord::Base
  belongs_to :parent_record, :polymorphic => true
  belongs_to :child_record, :polymorphic => true
  belongs_to :user, :polymorphic => true

  belongs_to :child_audit, :class_name => 'CollectionAudit'
  has_many :parent_audits, :class_name => 'CollectionAudit', :foreign_key => :child_audit_id
end
