module Mutations
  class UpdatePost < Mutations::BaseMutation
    argument :id, ID, required: true
    argument :title, String, required: false
    argument :body, String, required: false

    field :post, Types::PostType, null: true
    field :errors, [ String ], null: true

    def resolve(id:, **post_attributes)
      post = Post.find_by_id(id)
      unless post
        return {
          post: nil,
          errors: [ "Post not found." ]
        }
      end

      if post.update(post_attributes)
        {
          post: post,
          errors: []
        }
      else
        {
          post: nil,
          errors: post.errors.full_messages
        }
      end
    end
  end
end
