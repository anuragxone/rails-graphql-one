# app/graphql/loaders/association_loader_for_batch.rb
module Loaders
  class AssociationLoaderForBatch < GraphQL::Batch::Loader
    def initialize(model, association_name)
      super()
      @model = model # e.g., Post
      @association_name = association_name # e.g., :author
      @association = @model.reflect_on_association(@association_name)

      if @association.nil?
        raise ArgumentError, "No association #{@association_name} on #{@model.name}"
      end
      # puts "BATCH_LOADER_DEBUG: Initialized AssociationLoaderForBatch for #{@model.name}##{@association_name}"
    end

    def perform(records) # `records` are the parent objects, e.g., an array of Posts
      # puts "BATCH_LOADER_DEBUG: Perform for #{@model.name}##{@association_name} with #{records.size} records. First ID: #{records.first.try(:id)}"
      if records.empty?
        records.each { |record| fulfill(record, @association.collection? ? [] : nil) }
        return
      end

      # Manual Preloading Logic
      case @association.macro
      when :belongs_to
        # For belongs_to (e.g., Post.author)
        # 1. Get all foreign key IDs from the parent records
        foreign_key_name = @association.foreign_key
        # Collect non-nil foreign key values
        foreign_key_values = records.map { |r| r.public_send(foreign_key_name) }.compact.uniq

        # 2. Load all associated records (e.g., Authors) in one query
        # The associated class is @association.klass (e.g., Author)
        # The primary key on the associated class is usually :id
        associated_records_map = if foreign_key_values.any?
                                   @association.klass.where(id: foreign_key_values).index_by(&:id)
                                 else
                                   {}
                                 end

        # 3. Assign them back to the parent records
        records.each do |record|
          fk_value = record.public_send(foreign_key_name)
          associated_object = fk_value ? associated_records_map[fk_value] : nil
          fulfill(record, associated_object)
        end

      when :has_many, :has_one
        # For has_many (e.g., Author.posts) or has_one
        # 1. Get all primary key IDs from the parent records
        parent_ids = records.map(&:id).compact.uniq

        # 2. Load all associated records (e.g., Posts) in one query,
        #    grouped by the foreign key on the associated table.
        # The foreign key on the associated table that points back to the parent
        foreign_key_on_associated_table = @association.foreign_key

        # e.g., Post.where(author_id: [1,2,3]).group_by(&:author_id)
        associated_records_by_parent_id = if parent_ids.any?
                                            @association.klass.where(foreign_key_on_associated_table => parent_ids)
                                                        .group_by { |assoc_record| assoc_record.public_send(foreign_key_on_associated_table) }
                                          else
                                            {}
                                          end

        # 3. Assign them back
        records.each do |record|
          # For has_many, it's a collection (even if empty). For has_one, it's a single object or nil.
          associated_objects = associated_records_by_parent_id[record.id] || (@association.collection? ? [] : nil)
          fulfill(record, associated_objects)
        end
      else
        raise "Unsupported association macro: #{@association.macro} for #{@model.name}##{@association_name}"
      end
      # puts "BATCH_LOADER_DEBUG: Manual perform completed for #{@model.name}##{@association_name}."
    end

    # The load method remains the same, inherited from GraphQL::Batch::Loader
    # or you can define it for clarity as before:
    def load(record)
      super(record)
    end
  end
end