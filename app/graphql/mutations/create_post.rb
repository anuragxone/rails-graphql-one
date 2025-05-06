module Mutations
  class CreatePost < Mutations::BaseMutation
    argument :title, String, required: true
    argument :body, String, required: false
    argument :author_id, ID, required: true

    field :post, Types::PostType, null: true
    field :errors, [ String ], null: true

    def resolve(title:, body: nil, author_id:)
      if Author.exists?(id: author_id)
        post = Post.new(title: title, body: body, author_id: author_id)
        if post.save
          { post: post, errors: [] }
        end
      else
        {
          post: nil,
          errors: post.errors.full_messages
        }
      end
    end
  end
end
