require "spec_helper"
require "pry"

describe Liql do
  let(:layout) { File.read(File.expand_path("../support/layout.html.liquid", __FILE__)) }

  it "has a version number" do
    expect(Liql::VERSION).not_to be nil
  end

  it "binds assigns on terminal values" do
    ast = Liql.parse(<<-LIQUID)
      {% assign foo = 'foo' %}
      {% assign bar = 1 %}
      {% assign baz = false %}
    LIQUID

    foo_binding = ast.bindings["foo"].first
    terminal_foo = Liql::TerminalValue.new(value: "foo")
    expect(foo_binding).to(be_a(Liql::Variable))
    expect(foo_binding.refs).to(eq([terminal_foo]))

    bar_binding = ast.bindings["bar"].first
    terminal_bar = Liql::TerminalValue.new(value: 1)
    expect(bar_binding).to(be_a(Liql::Variable))
    expect(bar_binding.refs).to(eq([terminal_bar]))

    baz_binding = ast.bindings["baz"].first
    terminal_baz = Liql::TerminalValue.new(value: false)
    expect(baz_binding).to(be_a(Liql::Variable))
    expect(baz_binding.refs).to(eq([terminal_baz]))
  end

  it "binds variables when they're used in mustache" do
    ast = Liql.parse("{{ foo }}")
    binding = ast.bindings["foo"].first
    expect(binding).to(be_a(Liql::Variable))
    expect(binding.refs).to(eq([]))
  end

  it "ignores text" do
    ast = Liql.parse("THIS. IS. HTML!")
    expect(ast.bindings).to(be_empty)
  end

  it "binds all branches for if node" do
    ast = Liql.parse(<<-LIQUID)
      {% if foo %}
        {{ bar }}
      {% elsif baz %}
        {{ toto }}
      {% endif %}
    LIQUID

    expect(ast.bindings.keys).to(eq(%w(foo bar baz toto)))
    expect(ast.bindings.values.map(&:first)).to(all(be_a(Liql::Variable)))
  end

  it "binds with binops" do
    ast = Liql.parse("{% assign foo = bar != baz %}")
    foo_binding = ast.bindings["foo"].first
    bar_binding = ast.bindings["bar"].first
    baz_binding = ast.bindings["baz"].first

    expect(bar_binding).to(be_a(Liql::Variable))
    expect(baz_binding).to(be_a(Liql::Variable))
    expect(foo_binding).to(be_a(Liql::Variable))
    expect(foo_binding.refs).to(eq([Liql::TerminalValue.new(value: :bool)]))
  end

  # it "binds variables when they're used in filters" do
  #   ast = Liql.parse("{{ foo | bar: baz: toto }}")
  #   binding = ast.bindings["foo"].first
  #   expect(binding).to(be_a(Liql::Variable))
  #   expect(binding.refs).to(eq([]))
  # end

  it "assigns set references" do
    ast = Liql.parse("{% assign foo = bar %}")
    foo_binding = ast.bindings["foo"].first
    bar_binding = ast.bindings["bar"].first
    expect(foo_binding.refs.first).to(eq(bar_binding))
  end

  it "for node creates a new lexical scope with a reference variable" do
    ast = Liql.parse("{% for foo in foos %}%{% endfor %}")
    foos_binding = ast.bindings["foos"].first
    foo_binding = ast.children.first.bindings["foo"].first
    expect(foo_binding).to(be_a(Liql::Variable))
    expect(foo_binding.refs.first).to(eq(foos_binding))
  end

  it "for node infers that the thing is a collection" do
    ast = Liql.parse("{% for foo in foos %}%{% endfor %}")
    foos_binding = ast.bindings["foos"].first
    expect(foos_binding).to(be_a(Liql::Variable))
    expect(foos_binding.schema).to(be_a(Liql::CollectionSchema))
    expect(foos_binding.schema.item_schema).to(be_nil)
  end

  # it "does something useful" do
  #   ast = Liql.parse(layout)
  #   binding.pry
  #   expect(false).to eq(true)
  # end
end
