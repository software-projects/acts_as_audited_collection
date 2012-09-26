class <%= class_name %> < ActiveRecord::Migration
  def self.up
<% if version < [1,0,0] %>
    add_column :collection_audits, :current, :boolean, :default => true, :nullable => false
    add_index :collection_audits, :current

    execute %q{
      update collection_audits ca_old
        join collection_audits ca_new
        on ca_old.id < ca_new.id
        and ca_old.parent_record_type = ca_new.parent_record_type
        and ca_old.parent_record_id = ca_new.parent_record_id
        and ca_old.child_record_type = ca_new.child_record_type
        and ca_old.child_record_id = ca_new.child_record_id
        and ca_old.association = ca_new.association
      set ca_old.current = false
    }
<% end %>
  end

  def self.down
<% if version < [1,0,0] %>
    remove_index :collection_audits, :current
    remove_column :collection_audits, :current
<% end %>
  end
end
