# app/graphql/mutations/delete_author.rb
module Mutations
  class DeletePost < BaseMutation
    description "Deletes an existing blog author and their posts"

    # -- Arguments --
    argument :id, ID, required: true, description: "The ID of the author to delete"

    # -- Return Fields --
    # Let's return the ID of the deleted author on success
    field :deleted_id, ID, null: true, description: "The ID of the author that was deleted"
    field :errors, [ String ], null: true, description: "Errors that prevented deletion, if any"

    # -- Resolver --
    def resolve(id:)
      post = Post.find_by(id: id)
      unless post
        return { deleted_id: nil, errors: [ "Post with ID #{id} not found." ] }
      end

      # Use destroy to trigger callbacks (like dependent: :destroy for posts)
      if post.destroy
        # Success! Return the ID of the deleted author.
        {
          deleted_id: id, # Or author.id before it was destroyed
          errors: []
        }
      else
        # Less common for destroy to fail without raising an exception,
        # but maybe callbacks could prevent it.
        {
          deleted_id: nil,
          errors: author.errors.full_messages.presence || [ "Failed to delete author." ]
        }
      end
    end
  end
end
