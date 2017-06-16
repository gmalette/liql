$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "pry"
require "pry-nav"
require "support/schema"
require "liql"
require "rspec"

class MockNetworkLayer
  def initialize(mock_response)
    @mock_response = mock_response
  end

  def query(query)
    @mock_response
  end
end


RSpec::Matchers.define :be_a_variable do |expected|
  match do |actual|
    expected.class == actual.class &&
      expected.name == actual.name &&
      expected.schema == actual.schema &&
      expected.properties == actual.properties
  end
end
