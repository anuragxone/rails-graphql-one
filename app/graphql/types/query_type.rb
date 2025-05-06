# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [Types::NodeType, null: true], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ID], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World!"
    end

    field :all_authors, [ Types::AuthorType ], null: false
    def all_authors
      Author.all
    end

    field :author, Types::AuthorType, null: true, description: "Fetches an author given its ID." do
      argument :id, ID, required: true, description: "ID of the author."
    end

    def author(id:)
      Author.find(id)
    end

    field :all_posts, [ Types::PostType ], null: false
    def all_posts
      Post.all
    end

    field :post, Types::PostType, null: true, description: "Fetches a post" do
      argument :id, ID, required: true, description: "ID of the post."
    end
    def post(id:)
      Post.find(id)
    end
  end
end
