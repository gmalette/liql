require "spec_helper"
require "pry"

describe Liql do
  let(:layout) { File.read(File.expand_path("../support/layout.html.liquid", __FILE__)) }

  it "has a version number" do
    expect(Liql::VERSION).not_to be nil
  end

  it "binds assigns on terminal values" do
    mapping = Liql.parse(<<-LIQUID)
      {% assign foo = 'foo' %}
      {% assign bar = 1 %}
      {% assign baz = false %}
    LIQUID

    foo_binding = mapping.bindings["foo"].first
    terminal_foo = Liql::TerminalValue.new(value: "foo")
    expect(foo_binding).to(be_a(Liql::Variable))
    expect(foo_binding.ref).to(eq(terminal_foo))

    bar_binding = mapping.bindings["bar"].first
    terminal_bar = Liql::TerminalValue.new(value: 1)
    expect(bar_binding).to(be_a(Liql::Variable))
    expect(bar_binding.ref).to(eq(terminal_bar))

    baz_binding = mapping.bindings["baz"].first
    terminal_baz = Liql::TerminalValue.new(value: false)
    expect(baz_binding).to(be_a(Liql::Variable))
    expect(baz_binding.ref).to(eq(terminal_baz))
  end

  it "binds variables when they're used in mustache" do
    mapping = Liql.parse("{{ foo }}")
    binding = mapping.bindings["foo"].first
    expect(binding).to(be_a(Liql::Variable))
    expect(binding.ref).to(be_nil)
  end

  it "ignores text" do
    mapping = Liql.parse("THIS. IS. HTML!")
    expect(mapping.bindings).to(be_empty)
  end

  it "binds all branches for if node" do
    mapping = Liql.parse(<<-LIQUID)
      {% if foo %}
        {{ bar }}
      {% elsif baz %}
        {{ toto }}
      {% endif %}
    LIQUID

    expect(mapping.bindings.keys).to(eq(%w(foo bar baz toto)))
    expect(mapping.bindings.values.map(&:first)).to(all(be_a(Liql::Variable)))
  end

  it "binds with binops" do
    mapping = Liql.parse("{% assign foo = bar != baz %}")
    foo_binding = mapping.bindings["foo"].first
    bar_binding = mapping.bindings["bar"].first
    baz_binding = mapping.bindings["baz"].first

    expect(bar_binding).to(be_a(Liql::Variable))
    expect(baz_binding).to(be_a(Liql::Variable))
    expect(foo_binding).to(be_a(Liql::Variable))
    expect(foo_binding.ref).to(eq(Liql::TerminalValue.new(value: :bool)))
  end

  it "binds variables when they're used in filters" do
    mapping = Liql.parse("{{ foo | bar: baz: toto | tutu: tata }}")
    foo_binding = mapping.bindings["foo"].first
    toto_binding = mapping.bindings["toto"].first
    expect(foo_binding).to(be_a(Liql::Variable))
    expect(toto_binding).to(be_a(Liql::Variable))
  end

  it "assigns set references" do
    mapping = Liql.parse("{% assign foo = bar %}")
    foo_binding = mapping.bindings["foo"].first
    bar_binding = mapping.bindings["bar"].first
    expect(foo_binding.ref).to(eq(bar_binding))
  end

  it "for node creates a new lexical scope with a reference variable" do
    mapping = Liql.parse("{% for foo in foos %}%{% endfor %}")
    foos_binding = mapping.bindings["foos"].first
    foo_binding = mapping.children.first.bindings["foo"].first
    expect(foo_binding).to(be_a(Liql::Variable))
    expect(foo_binding.ref).to(eq(foos_binding))
  end

  it "for node infers that the thing is a collection" do
    mapping = Liql.parse("{% for foo in foos %}%{% endfor %}")
    foos_binding = mapping.bindings["foos"].first
    expect(foos_binding).to(be_a(Liql::Variable))
    expect(foos_binding.schema).to(be_a(Liql::CollectionSchema))
    expect(foos_binding.schema.item_schema).to(be_nil)
  end

  it "can augment properties of variables through re-bound variables" do
    mapping = Liql.parse(<<-LIQUID)
      {% assign p = product %}
      {{ p.variants }}
      {% assign foo = p %}
      {{ foo.handle }}
    LIQUID
    product_binding = mapping.bindings["product"].first
    expect(product_binding).to(be_a(Liql::Variable))
    expect(product_binding.properties["variants"]).to(be_a(Liql::Variable))
    expect(product_binding.properties["handle"]).to(be_a(Liql::Variable))
  end

  it "can augment properties on index-access if the property is a terminal value"
end
