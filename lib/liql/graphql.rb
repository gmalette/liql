require 'graphql/compiler'

module Liql
  module GraphQL
    attr_accessor :network_layer

    def self.render_liquid(template)
      ast = Liql.parse(template)
      query = Compiler.new(ast).compile

      response = network_layer.query(query)

      # TODO turn response into drop for template
      # Liquid::Template.parse ?
      # template.render ?
    end
  end
end
