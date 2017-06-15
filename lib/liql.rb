require "liql/version"
require "liql/graphql/compiler"
require "liql/graphql/network_layer"
require "liquider"
require "securerandom"

module Liql
  class << self
    def parse(template)
      ast = Liquider::Parser.new([], Liquider::Scanner.new(Liquider::TextStream.new(template))).parse
      lexical_scope = LexicalScope.new
      eval_ast(ast, lexical_scope)
      lexical_scope
    end

    private

    def eval_ast(ast, lexical_scope)
      case ast
      when Liquider::Ast::DocumentNode
        ast.elements.map { |node| eval_ast(node, lexical_scope) }
        nil
      when Liquider::Ast::TextNode
        nil
      when Liquider::Ast::IfNode
        eval_ast(ast.head, lexical_scope)
        eval_ast(ast.body, lexical_scope)
        eval_ast(ast.continuation, lexical_scope)
        nil
      when Liquider::Ast::CallNode
        target = eval_ast(ast.target, lexical_scope)
        property = ast.property.name
        target.properties[property] ||
          target.add_property(name: property, property: Variable.new(name: property))
      when Liquider::Ast::SymbolNode
        lexical_scope.find_binding(name: ast.name)
      when Liquider::Ast::MustacheNode
        eval_ast(ast.expression, lexical_scope)
        nil
      when Liquider::Ast::BinOpNode
        eval_ast(ast.left, lexical_scope)
        eval_ast(ast.right, lexical_scope)
        TerminalValue.new(value: :bool)
      when Liquider::Ast::NegationNode
        eval_ast(ast.expression, lexical_scope)
        TerminalValue.new(value: :bool)
      when Liquider::Ast::NumberNode
        TerminalValue.new(value: ast.value)
      when Liquider::Ast::StringNode
        TerminalValue.new(value: ast.value)
      when Liquider::Ast::BooleanNode
        TerminalValue.new(value: ast.value)
      when Liquider::Ast::ForNode
        value = eval_ast(ast.expression, lexical_scope)
        unless value.schema.is_a?(Liql::CollectionSchema)
          value.schema = Liql::CollectionSchema.new(item_schema: nil, schema: value.schema)
        end
        child_scope = lexical_scope.add_child_scope
        assign = child_scope.create_binding(ast.binding.name, ref: value)
        eval_ast(ast.body, child_scope)
        nil
      when Liquider::Ast::AssignNode
        value = eval_ast(ast.value, lexical_scope)
        lexical_scope.create_binding(ast.binding.name, ref: value)
        value
      when Liquider::Ast::FilterNode
        eval_ast(ast.arg_list, lexical_scope)
        nil
      when Liquider::Ast::ArgListNode
        ast.positionals.each { | pos| eval_ast(pos, lexical_scope) }
        ast.optionals.each { |opt| eval_ast(opt, lexical_scope) }
      when Liquider::Ast::OptionPairNode
        eval_ast(ast.value, lexical_scope)
      when Liquider::Ast::NullNode
        nil
      else
        raise "unsupported: #{ast.class.name}"
        nil
      end
    end
  end

  LexicalScope = Struct.new(:parent, :children, :bindings) do
    def initialize(parent: nil)
      self.parent = parent
      self.children = []
      self.bindings = {}
    end

    def add_child_scope
      new_scope = LexicalScope.new(parent: self)
      children << new_scope
      new_scope
    end

    def find_binding(name:)
      bindings[name]&.last ||
        parent&.find_binding(name: name) ||
        create_binding(name)
    end

    def create_binding(name, ref: nil)
      var = Variable.new(name: name, ref: ref)
      bindings[name] ||= []
      bindings[name].push(var)
      var
    end

    def root
      parent&.root || self
    end
  end

  TerminalValue = Struct.new(:value) do
    def initialize(value:)
      self.value = value
    end
  end

  Variable = Struct.new(:name, :schema, :ref, :properties, :id) do
    def initialize(name:, schema: nil, ref: nil)
      self.id = SecureRandom.hex
      self.name = name
      self.schema = schema
      self.properties = {}
      self.ref = ref
    end

    def ref?
      !ref.nil?
    end

    def add_property(name:, property:)
      if ref
        ref.add_property(name: name, property: property)
      end
      self.properties[name] = property
    end
  end

  CollectionSchema = Struct.new(:schema, :item_schema, :id) do
    def initialize(item_schema: nil, schema: nil)
      self.id = SecureRandom.hex
      self.schema = schema
      self.item_schema = item_schema
    end
  end
end
