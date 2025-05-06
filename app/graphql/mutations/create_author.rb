module Mutations
  class CreateAuthor < BaseMutation
    argument :name, String, required: true, description: "The name of the author"
    argument :email, String, required: true, description: "The email of the author"

    field :author, Types::AuthorType, null: true, description: "The author that was created"
    field :errors, [ String ], null: true, description: "There was an error creating the author"

    def resolve(name:, email:)
      author = Author.new(name: name, email: email)
      if author.save
        {
          author: author,
          errors: []
        }
      else
        {
          author: nil,
          errors: author.errors.full_messages
        }
      end
    end
  end
end
