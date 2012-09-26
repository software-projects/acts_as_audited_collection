acts\_as\_audited\_collection
==========================

acts\_as\_audited\_collection is a Rails plugin, which extends ActiveRecord to allow auditing of associations.

The basic feature set is:

- Tracking addition of child records to an association
- Tracking removal of child records
- Tracking a child record being reassociated with a new parent, as a remove followed by an add
- (Optionally) tracking any children which are modified
- (Optionally) tracking when a grandchild is modified by cascading through associations

License
-------

This plugin is released under the MIT license, and was contributed to the Rails community by the good people at [Software Projects](http://sp.com.au/).

Installation
============

Add this line to your application's Gemfile:

    gem 'acts_as_audited_collection'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acts_as_audited_collection

Generating the migration
------------------------

    script/generate audited_collection_migration add_collection_audits_table
    rake db:migrate

Upgrading
---------

Specify the version you're upgrading *from* as a parameter.

    rails generate audited_collect_migration upgrade_collection_audits_table 0.4.0
    rake db:migrate

Usage
=====

Declare an association that looks like:

    class Employer < ActiveRecord::Base
      has_many :people
      acts_as_audited_collection_parent :for => :people
    end

    class Person < ActiveRecord::Base
      belongs_to :employer
      acts_as_audited_collection :parent => :employer
    end

When a record is created
-------------------------

    Person.create :name => 'Fred', :employer => nil   # No audit record

    e = Employer.create :name => 'Foo Inc.'           # No audit record
    Person.create :name => 'Mary', :employer => e     # Audit record is created

    e.people_audits.last.action                       # 'add'
    e.people_audits.last.parent_record                # Employer name: 'Foo Inc.'
    e.people_audits.last.child_record                 # Person name: 'Mary'

Tracking removal
----------------

    e.people.create :name => 'Bob'                    # Audit record is created

    e.people.last.destroy                             # Audit record is created

    e.people_audits.last.action                       # 'remove'
    e.people_audits.last.parent_record                # Employer name: 'Foo Inc.'
    e.people_audits.last.child_record                 # nil   (record was destroyed)
    e.people_audits.last.child_record_id              # 3    (for example)
    e.people_audits.last.child_record_type            # 'Person'

Tracking reassociation
----------------------

    p = Person.first                                  # Person name: 'Fred'
    p.update_attributes :employer => e                # Audit record is created

    e.people_audits.last.action                       # 'add'

    e2 = Employer.create :name => 'Bar Ltd.'          # No audit record
    p.update_attributes :employer => e2               # Two audit records!

    e.people_audits.last.action                       # 'remove'
    e2.people_audits.last.action                      # 'add'

    p.update_attributes :employer => e                # Changing it back for the sake of my own sanity.

Tracking modification of unrelated attributes
----------------------------------------------

Consider the following alternative "Person" model.

    class Person < ActiveRecord::Base
      belongs_to :employer
      acts_as_audited_collection :parent => :employer,
          :track_modifications => true
    end

With this, we can now see modifications from the parent (though we make no attempt to ascertain what the modifications were - if you need this, see [acts_as_audited](http://github.com/collectiveidea/audited))

    p = Person.first                                  # Person name: 'Fred'
    p.update_attributes :name => 'Freda'              # Audit record is created

    e.people_audits.last.action                       # 'modify'
    e.people_audits.last.child_record                 # Person name: 'Freda'

Tracking deep changes to the model hierarchy
--------------------------------------------

Consider now that a Person might have any number of hobbies.

    class Person < ActiveRecord::Base
      belongs_to :employer
      has_many :hobbies

      acts_as_audited_collection :parent => :employer,
          :track_modifications => true

      acts_as_audited_collection_parent :for => :hobbies
    end

    class Hobby < ActiveRecord::Base
      belongs_to :person

      acts_as_audited_collection :parent => :person,
          :cascade => true  # Cascades audit events to the parent
    end

The `:cascade => true` option specifies that the audit event in the child record should cascade upward, marking the parent as modified, and therefore generating a `'modify'` audit record in any grandparent for which `:track_modifications => true` has been specified..

    p = Person.first                                  # Person name: 'Freda'
    p.hobbies.create :name => 'Model Trains'          # Two audit records created.

    p.hobbies_audits.last.action                      # 'add'
    e.people_audits.last.action                       # 'modify'
    e.people_audits.last.child_record                 # Person name: 'Freda'
    e.people_audits.last.parent_record                # Employer name: 'Foo Inc.'

Temporarily disabling auditing
------------------------------

    Person.without_collection_audit do
      p.update_attributes :name => 'Fred'             # No audit record
    end

Keep in mind that this disables collection auditing completely in the current thread, not just for the `Person` model.

Contributing
============

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
