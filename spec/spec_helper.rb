require "pry"

require_relative "lib/matchers"
require_relative "lib/colorize"
require_relative "lib/test_client"
require_relative "lib/test_server"

RSpec.configure do |config|
  config.include Helpers
end
