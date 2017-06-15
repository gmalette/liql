require "spec_helper"
require "pry"

describe Liql do
  let(:ast) { Liql.parse(File.read(File.expand_path("../support/graphql.html.liquid", __FILE__))) }
  let(:compiled) { Liql::GraphqlCompiler.new(ast).compile }

  it "generates a graphql query from an ast" do
    expected = "query LiquidTemplate {\n  shop {\n    name\n    description\n  }\n}"
    expect(compiled.to_query_string).to eq(expected)
  end
end
