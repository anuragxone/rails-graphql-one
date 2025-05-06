# app/graphql/loaders/association_loader.rb
module Loaders
  class AssociationLoader < GraphQL::Dataloader::Source
    def initialize(model, association_name)
      super()
      @model = model
      @association_name = association_name
      puts "LOADER_DEBUG: Initialized AssociationLoader for #{@model.name}##{@association_name}"
    end

    def fetch(records)
      puts "LOADER_DEBUG: Fetch called with #{records.size} records. First record ID: #{records.first.try(:id)}"
      puts "LOADER_DEBUG: Model: #{@model.name}, Association: #{@association_name}"

      # Ensure records is not empty before attempting to preload
      if records.empty?
        puts "LOADER_DEBUG: No records to preload."
        return [] # Dataloader expects an array of results matching the input records
      end

      begin
        # Using the class method directly.
        # This method should modify the 'records' array in place.
        ::ActiveRecord::Associations::Preloader.preload(records, @association_name)

        puts "LOADER_DEBUG: Preloading attempted with ::ActiveRecord::Associations::Preloader.preload(records, @association_name). Records count: #{records.count}"

        # Check if association is loaded on the first record
        if records.first.association(@association_name).loaded?
          puts "LOADER_DEBUG: Association '#{@association_name}' IS LOADED on first record after preload."
        else
          puts "LOADER_DEBUG: Association '#{@association_name}' IS NOT LOADED on first record after preload. This is the problem point."
        end

      rescue ArgumentError => e
        # This might happen if this form of `preload` also expects keywords in your Rails version
        puts "LOADER_DEBUG: ARGUMENT ERROR during ::ActiveRecord::Associations::Preloader.preload: #{e.message}"
        puts "LOADER_DEBUG: This suggests ::ActiveRecord::Associations::Preloader.preload might also need keyword args in your Rails version, or another Preloader API."
        # If this fails, we might need to explore preloader.rb source for your Rails version.
        raise
      rescue StandardError => e
        puts "LOADER_DEBUG: UNEXPECTED ERROR during preload: #{e.class} - #{e.message}"
        raise
      end

      # The map part
      results = records.map do |record|
        # If preloading worked, this access should not trigger a new DB query.
        associated_object = record.public_send(@association_name)
        associated_object
      end
      puts "LOADER_DEBUG: Map completed. Results count: #{results.size}. First result class: #{results.first.class if results.any? && results.first}"

      return results
    end
  end
end