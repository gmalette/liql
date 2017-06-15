require "spec_helper"
require "pry"

describe Liql do
  let(:layout) { File.read(File.expand_path("../support/layout.html.erb", __FILE__)) }

  it "has a version number" do
    expect(Liql::VERSION).not_to be nil
  end

  it "does something useful" do
    ast = Liql.parse(layout)
    binding.pry
    expect(false).to eq(true)
  end
end
