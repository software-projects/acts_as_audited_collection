# ActsAsAuditedCollection

require 'acts_as_audited_collection/collection_audit.rb'

module ActiveRecord
  module Acts
    module AuditedCollection
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_audited_collection(options = {})
          unless self.included_modules.include?(InstanceMethods)
            # First time use in this class, we have some extra work to do.
            send :include, InstanceMethods 

            class_inheritable_reader :audited_collections
            write_inheritable_attribute :audited_collections, {}

            after_create :collection_audit_create
            before_update :collection_audit_update
            after_destroy :collection_audit_destroy

            has_many :child_collection_audits, :as => :child_record,
              :class_name => 'CollectionAudit'
          end

          options = {
            :name => self.class_name.tableize.to_sym
          }.merge(options)

          unless options.has_key? :parent
            raise ActiveRecord::ConfigurationError.new "Must specify parent for an acts_as_audited_collection (:parent => :object)"
          end

          parent_association = reflect_on_association(options[:parent])
          unless parent_association && parent_association.belongs_to?
            raise ActiveRecord::ConfigurationError.new "Parent association '#{options[:parent]}' must be a belongs_to relationship"
          end

          # Try explicit first, then default
          options[:foreign_key] ||= parent_association.options[:foreign_key]
          options[:foreign_key] ||= parent_association.primary_key_name

          # TODO Remove this when polymorphic is supported.
          if parent_association.options[:polymorphic]
            raise ActiveRecord::ConfigurationError.new "Sorry, acts_as_audited_collection polymorphic associations haven't been added yet."
          end

          options[:parent_type] ||= parent_association.klass.class_name

          define_acts_as_audited_collection options do |config|
            config.merge! options
          end
        end

        def acts_as_audited_collection_parent(options = {})
          unless options.has_key? :for
            raise ActiveRecord::ConfigurationError.new "Must specify relationship for an acts_as_audited_collection_parent (:for => :objects)"
          end

          child_association = reflect_on_association(options[:for])
          if child_association.nil? || child_association.belongs_to?
            raise ActiveRecord::ConfigurationError.new "Association '#{options[:for]}' must be a valid parent (i.e. not belongs_to) relationship"
          end

          has_many :"#{options[:for]}_audits", :as => :parent_record,
              :class_name => 'CollectionAudit',
              :conditions => ['association = ?', options[:for].to_s]
        end

        def define_acts_as_audited_collection(options)
          yield(read_inheritable_attribute(:audited_collections)[options[:name]] ||= {})
        end
      end

      module InstanceMethods
        protected
        def collection_audit_create
          collection_audit_write :action => 'add', :attributes => audited_collection_attributes
        end

        def collection_audit_update
          unless (old_values = audited_collection_attribute_changes).empty?
            new_values = old_values.inject({}) { |map, (k, v)| map[k] = self[k]; map }

            collection_audit_write :action => 'remove', :attributes => old_values
            collection_audit_write :action => 'add', :attributes => new_values
          end
        end

        def collection_audit_destroy
          collection_audit_write :action => 'remove', :attributes => audited_collection_attributes
        end

        private
        def collection_audit_write(opts)
          mappings = audited_relation_attribute_mappings
          opts[:attributes].reject{|k,v| v.nil?}.each do |name, fk|
            child_collection_audits.create :parent_record_id => fk,
              :parent_record_type => mappings[name][1],
              :action => opts[:action],
              :association => mappings[name][0].to_s
          end
        end

        def audited_collection_attributes
          attributes.slice *audited_relation_attribute_mappings.keys
        end

        def audited_collection_attribute_changes
          changed_attributes.slice *audited_relation_attribute_mappings.keys
        end

        def audited_relation_attribute_mappings
          audited_collections.inject({}) do |map, (name, options)|
            map[options[:foreign_key]] = [name, options[:parent_type]]
            map
          end
        end
      end
    end
  end
end
