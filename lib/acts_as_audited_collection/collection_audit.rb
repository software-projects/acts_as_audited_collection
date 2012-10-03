# Released under the MIT license. See the LICENSE file for details
require 'active_record'

class CollectionAudit < ActiveRecord::Base
  belongs_to :parent_record, :polymorphic => true
  belongs_to :child_record, :polymorphic => true
  belongs_to :user, :polymorphic => true

  belongs_to :child_audit, :class_name => 'CollectionAudit'
  has_many :parent_audits, :class_name => 'CollectionAudit', :foreign_key => :child_audit_id

  before_create :set_as_current

  scope :for_child, lambda{|c| where(:child_record_type => c.class.name, :child_record_id => c.id)}

  private
  def set_as_current
    self.class.where(
      :parent_record_type => parent_record_type,
      :parent_record_id => parent_record_id,
      :child_record_type => child_record_type,
      :child_record_id => child_record_id,
      :audited_association => audited_association,
      :current => true
    ).update_all :current => false
    self.current = true
  end
end
