# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World"
    end

    field :create_author, mutation: Mutations::CreateAuthor
    field :create_post, mutation: Mutations::CreatePost
    field :update_author, mutation: Mutations::UpdateAuthor # <--- Add this line
    field :update_post, mutation: Mutations::UpdatePost
    field :delete_author, mutation: Mutations::DeleteAuthor # <--- Add this line
    field :delete_post, mutation: Mutations::DeletePost
  end
end
