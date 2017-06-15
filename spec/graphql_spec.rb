require "spec_helper"
require "pry"

describe Liql::GraphQL do
  let(:template) { File.read(File.expand_path("../support/graphql.html.liquid", __FILE__)) }
  let(:mock_response) {
    {
      "data" => {
        "shop" => {
          "name" => "yolo",
          "description" => "lol",
          "address" => {
            "city" => "Montreal",
            "zip" => "g1q 1q9",
          }
        }
      }
    }
  }

  it "renders a template with GraphQL data" do
    old_network_layer = Liql::GraphQL.network_layer
    Liql::GraphQL.network_layer = MockNetworkLayer.new(mock_response)

    expected = <<~HTML
      <!doctype html>
      <html>
        <head>
          <title>
            yolo
          </title>
        </head>
        <body>
          lol

          <div>Montreal</div>
          <div>g1q 1q9</div>


          <p>g1q 1q9</p>

          <p></p>
        </body>
      </html>
    HTML

    result = Liql::GraphQL.render_liquid(template)

    expect(result).to eq(expected)

    Liql::GraphQL.network_layer = old_network_layer
  end
end
