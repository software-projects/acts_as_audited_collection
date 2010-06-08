# ActsAsAuditableCollection

module ActiveRecord
  module Acts
    module AuditableCollection
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_auditable_collection(options = {})
          unless self.included_modules.include?(InstanceMethods)
            send :include, InstanceMethods 
            class_inheritable_reader :auditable_collections
            write_inheritable_attribute :auditable_collections, {}
          end

          options = {
            :name => self.class_name.tableize.to_sym
          }.merge(options)

          unless options.has_key? :parent
            raise ActiveRecord::ConfigurationError.new "Must specify parent for an acts_as_auditable_collection"
          end
          parent_association = reflect_on_association(options[:parent])
          unless parent_association && parent_association.belongs_to?
            raise ActiveRecord::ConfigurationError.new "Parent association '#{options[:parent]}' must be a belongs_to relationship"
          end
          
          define_acts_as_auditable_collection options do |config|
            config.merge! options
          end
        end

        def define_acts_as_auditable_collection(options)
          yield (read_inheritable_attribute(:auditable_collections)[options[:name]] ||= {})
        end
      end

      module InstanceMethods
      end
    end
  end
end
