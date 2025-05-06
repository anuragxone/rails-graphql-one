# app/graphql/types/post_type.rb
module Types
  class PostType < Types::BaseObject
    description "A blog post"

    field :id, ID, null: false
    field :title, String, null: false
    field :body, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # We need to link this post back to its author.
    # How do we expose the Author object itself, not just the ID?
    field :author, Types::AuthorType, null: false
  end
end
