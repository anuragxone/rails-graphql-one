# app/graphql/loaders/record_loader.rb
module Loaders
  class RecordLoader < GraphQL::Batch::Loader
    def initialize(model)
      super() # Call super with no arguments
      @model = model
    end

    # `ids` will be an array of IDs to load
    def perform(ids)
      # Fetch records by IDs. `index_by(&:id)` creates a hash keyed by record ID.
      records_by_id = @model.where(id: ids).index_by(&:id)
      # Fulfill the promise for each ID with the found record or nil
      ids.each { |id| fulfill(id, records_by_id[id]) }
    end
  end
end