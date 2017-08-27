require "rspec"
require "pry"
require "open3"
require "yaml"

require_relative "matchers"
require_relative "colorize"
require_relative "test_client"
require_relative "test_server"

RSpec.configure do |config|
  config.include ::Helpers

  config.backtrace_exclusion_patterns += [
    /parser\.rb/
  ]

  config.before(:suite) do
    project = ENV["MUD_PROJECT"] || begin
      puts "MUD_PROJECT not defined, defaulting to ruby/stdlib"
      "ruby/stdlib"
    end

    $settings = YAML.load(File.read("#{project}/settings.yml"))

    if debugger_match = $settings["debugger_match"]
      debug_regexp = Regexp.new(debugger_match)
    end

    $server = TestServer.new(
      log: STDOUT,
      port: $settings["port"],
      command: $settings["start"],
      debug_regexp: debug_regexp,
      project_dir: project
    )
  end

  config.before(:each) do
    @log = STDOUT
    $server.start
  end

  config.after(:each) do
    if teardown = $settings["teardown"]
      Open3.capture3 teardown
    end
    $server.stop
  end
end
