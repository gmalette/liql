$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "liql"
require "rspec"
require "pry"
require "pry-nav"
require "support/schema"

class MockNetworkLayer
  def initialize(mock_response)
    @mock_response = mock_response
  end

  def query(query)
    @mock_response
  end
end
