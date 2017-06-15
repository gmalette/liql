module Liql
  module GraphQL
    class << self
      attr_accessor :network_layer
      attr_accessor :schema
    end

    def self.render_liquid(template)
      ast = Liql.parse(template)
      query = Compiler.new(ast).compile

      response = self.network_layer.query(query)
      data = response["data"]

      template = Liquid::Template.parse(template)
      template.render(data)
    end
  end
end
