module Liql
  Type = Struct.new(:properties) do
    def initialize(properties:)
      super(properties)
    end

    def harmonize(owner, properties)
      properties.values.flatten.each do |property|
        type = self.properties.fetch(property.name, Liql::Type::Undefined)
        case type
        when Liql::Type::Method
          type.fill(owner, self, property)
        when Liql::Type::Scalar
          # noop
        when Liql::Type::Undefined
          raise "Cannot harmonize #{property.name} on #{owner.inspect}"
        when Liql::Type::Collection
          binding.pry
          :toto
        when Liql::Type
          type.harmonize(property, property.properties)
        else
          raise "unhandled #{type.inspect}"
        end
      end
    end
  end

  class Type
    Undefined = Class.new do |c|
      def c.harmonize(_, _)
        raise "Cannot be harmonized"
      end
    end

    Collection = Struct.new(:item_type) do
      def initialize(item_type: nil)
        super(item_type)
      end

      def harmonize(_, value)
        binding.pry
        :toto
      end
    end

    Scalar = Class.new

    Method = Struct.new(:dependencies) do
      def initialize(dependencies:)
        super(dependencies)
      end

      def fill(owner, owner_type, property)
        dependencies.each do |chain|
          current_receiver = owner
          current_type = owner_type
          chain.split(".").each do |call|
            prop = current_receiver.properties[call] || current_receiver.add_property(name: call)
            current_type = current_type.properties.fetch(call, Liql::Type::Undefined)
            current_type.harmonize(current_receiver, prop)
            current_receiver = prop
          end
        end
      end
    end

    Function = Struct.new(:arguments, :calls) do
      def initialize(arguments:, calls:)
        super(arguments, calls)
      end
    end
  end
end
