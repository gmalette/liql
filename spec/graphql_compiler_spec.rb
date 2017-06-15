require "spec_helper"
require "pry"

describe Liql do
  let(:ast) { Liql.parse(File.read(File.expand_path("../support/graphql.html.liquid", __FILE__))) }
  let(:compiled) { Liql::GraphqlCompiler.new(ast).compile }

  it "generates a graphql query from an ast" do
    expected = <<~GRAPHQL.strip
      query LiquidTemplate {
        shop {
          name
          description
          address {
            city
            zip
          }
        }
      }
    GRAPHQL
    expect(compiled.to_query_string).to eq(expected)
  end
end
