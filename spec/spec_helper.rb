require "pry"
require "open3"
require "yaml"

require_relative "lib/matchers"
require_relative "lib/colorize"
require_relative "lib/test_client"
require_relative "lib/test_server"

RSpec.configure do |config|
  config.include Helpers

  config.before(:suite) do
    project = ENV["MUD_PROJECT"] || begin
      puts "MUD_PROJECT not defined, defaulting to ruby/stdlib"
      "ruby/stdlib"
    end

    Dir.chdir(project)

    $settings = YAML.load(File.read("settings.yml"))
  end

  config.before(:each) do
    @log = STDOUT

    if debugger_match = $settings["debugger_match"]
      debug_regexp = Regexp.new(debugger_match)
    end

    @server = TestServer.new(
      log: @log,
      port: $settings["port"],
      command: $settings["start"],
      debug_regexp: debug_regexp
    )

    @server.start
  end

  config.after(:each) do
    if teardown = $settings["teardown"]
      Open3.capture3 teardown
    end
    @server.stop
  end
end
