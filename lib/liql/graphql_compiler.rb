require 'graphql'

module Liql
  class GraphqlCompiler
    def initialize(ast)
      @ast = ast
    end

    def compile
      GraphQL::Language::Nodes::Document.new(
        definitions: [
          GraphQL::Language::Nodes::OperationDefinition.new(
            operation_type: 'query',
            name: 'LiquidTemplate',
            selections: get_selections_for_bindings(@ast.bindings)
          )
        ]
      )
    end

    private

    def get_selections_for_bindings(binding_sets)
      (binding_sets.values.map do |binding_set|
        binding_set.map do |bind|
          GraphQL::Language::Nodes::Field.new(
            name: bind.name,
            selections: get_selections_for_properties(bind.properties)
          )
        end
      end).flatten
    end

    def get_selections_for_properties(properties)
      return [] unless properties

      properties.values.map do |property|
        GraphQL::Language::Nodes::Field.new(
          name: property.name,
          selections: get_selections_for_properties(property.properties)
        )
      end
    end
  end
end
