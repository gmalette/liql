require 'graphql'

module Liql
  module GraphQL
    class Compiler
      Error = Class.new(StandardError)

      def initialize(ast, root: nil)
        @ast = ast
        @root = root
      end

      def compile
        query = ::GraphQL::Language::Nodes::Document.new(
          definitions: [
            ::GraphQL::Language::Nodes::OperationDefinition.new(
              operation_type: 'query',
              name: 'LiquidTemplate',
              selections: get_selections_for_bindings(@ast.bindings)
            )
          ]
        )

        validate_query_against_schema(query)

        query
      end

      private

      def get_selections_for_bindings(binding_sets)
        selections = binding_sets.values.map do |binding_set|
          binding_set.map { |bind| build_field_from_binding(bind) }
        end

        selections.flatten.compact
      end

      def build_field_from_binding(bind)
        return if bind.ref?

        ::GraphQL::Language::Nodes::Field.new(
          name: bind.name,
          selections: get_selections_from_properties(bind.properties)
        )
      end

      def get_selections_from_properties(properties)
        return [] unless properties

        properties.values.map do |property|
          ::GraphQL::Language::Nodes::Field.new(
            name: property.name,
            selections: get_selections_from_properties(property.properties)
          )
        end
      end

      def validate_query_against_schema(query)
        if schema = Liql::GraphQL.schema
          built_schema = ::GraphQL::Schema.from_introspection(schema)
          errors = built_schema.validate(query)

          if errors.any?
            raise Error.new(errors.first.message)
          end
        end
      end
    end
  end
end
