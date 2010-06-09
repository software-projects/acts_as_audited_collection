# Released under the MIT license. See the LICENSE file for details

class CollectionAudit < ActiveRecord::Base
  belongs_to :parent_record, :polymorphic => true
  belongs_to :child_record, :polymorphic => true
  belongs_to :user, :polymorphic => true
end
