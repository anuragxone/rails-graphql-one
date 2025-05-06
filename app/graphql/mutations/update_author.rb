# frozen_string_literal: true

module Mutations
  class UpdateAuthor < BaseMutation
    description "Updates an existing blog author"

    argument :id, ID, required: true
    argument :name, String, required: false
    argument :email, String, required: false

    field :author, Types::AuthorType, null: true
    field :errors, [String], null: true

    def resolve(id:, **author_attributes)
      author = Author.find_by(id: id)

      unless author
        return {
          author: nil,
          errors: [ "Author not found." ]
        }
      end

      if author.update(author_attributes)
        # Success! Return the updated author and no errors.
        {
          author: author,
          errors: []
        }
      else
        # Failed. Return nil for the author, and the validation errors.
        {
          author: nil,
          errors: author.errors.full_messages
        }
      end
    end


  end
end