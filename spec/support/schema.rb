Query = GraphQL::ObjectType.define do
  name "Query"
  field :a, types.String
end

Schema = GraphQL::Schema.define do
  query Query
end
