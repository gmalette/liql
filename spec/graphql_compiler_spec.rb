require "spec_helper"
require "pry"

describe Liql::GraphQL::Compiler do
  let(:ast) { Liql.parse(File.read(File.expand_path("../support/graphql.html.liquid", __FILE__))) }
  let(:compiled) { Liql::GraphQL::Compiler.new(ast).compile }

  it "raises errors when query does not match the schema" do
    old_schema = Liql::GraphQL.schema
    Liql::GraphQL.schema = Schema.as_json

    expect { Liql::GraphQL::Compiler.new(ast).compile }.to raise_error(Liql::GraphQL::Compiler::Error)

    Liql::GraphQL.schema = old_schema
  end

  it "generates a graphql query from an ast" do
    expected = <<~GRAPHQL.strip
      query LiquidTemplate {
        shop {
          name
          description
          address {
            city
            zip {
              upcase
            }
          }
        }
      }
    GRAPHQL

    expect(compiled.to_query_string).to eq(expected)
  end
end
