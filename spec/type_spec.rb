require "spec_helper"

describe Liql::Type do
  let(:shop_type) {
    Liql::Type.new(
      properties: {
        "currency" => Liql::Type::Scalar,
        "name" => Liql::Type::Scalar,
      }
    )
  }
  let(:product_type) {
    Liql::Type.new(
      properties: {
        "variants" => Liql::Type::Collection.new(item_type: -> { variant_type }),
        "available" => Liql::Type::Method.new(dependencies: ["variants.available"]),
        "compare_at_price_range" => Liql::Type::Method.new(dependencies: ["variants.compare_at_price"]),
      }
    )
  }
  let(:variant_type) {
    Liql::Type.new(
      properties: {
        "title" => Liql::Type::Scalar,
        "handle" => Liql::Type::Scalar,
        "compare_at_price" => Liql::Type::Scalar,
      }
    )
  }
  let(:top_level_type) {
    Liql::Type.new(
      properties: {
        "shop" => shop_type,
        "product" => product_type,
      }
    )
  }
  let(:scope) {
    Liql::LexicalScope.new(
      bindings: {
        "product" => [
          Liql::Variable.new(
            name: "product",
            properties: {
              "compare_at_price_range" => Liql::Property.new(
                name: "compare_at_price_range",
              ),
              "variants" => Liql::Property.new(
                name: "variants",
                schema: Liql::CollectionSchema.new(item_schema: nil)
              )
            }
          )
        ]
      }
    )
  }

  it "can describe complex types" do
    new_bindings = top_level_type.harmonize(nil, scope.as_call_tree)
    binding.pry
    :toto
  end
end
