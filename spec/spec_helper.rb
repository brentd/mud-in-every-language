require_relative "lib/matchers"
require_relative "lib/test_client"
require_relative "lib/test_server"

RSpec.configure do |c|
  c.include Helpers
end
