require "minitest/autorun"

$LOAD_PATH.unshift(File.dirname(__FILE__))

require "colorize"
require "test_client"
require "test_server"
require "builder"
require "reporter"
require "parser"

module Minitest
  def self.init_plugins(options)
    self.reporter.reporters.clear
    self.reporter << MudInEveryLanguage::Spec::Reporter.new(options[:io], options)
  end
end

module MudInEveryLanguage
  class Project
    attr_reader :dir, :settings, :server

    def initialize(dir)
      @dir = Pathname.new(dir)
      @settings = YAML.load(@dir.join("settings.yml").read)
    end
  end
end

project = MudInEveryLanguage::Project.new(ENV["MUD_PROJECT"])

server = TestServer.new(
  project_dir:  project.dir,
  port:         project.settings["port"],
  command:      project.settings["start"],
  log:          STDOUT,
  # debug_regexp: debug_regexp
)

if ARGV[0]
  file, line_number = ARGV[0].split(":")
end

parsed_files = begin
  if file
    TestParser.new.parse(File.read(file))
  else
    Dir["spec/*_test"].map do |f|
      TestParser.new.parse(File.read(f))
    end
  end
rescue Parslet::ParseFailed => e
  puts e.cause.ascii_tree
end

if line_number
  parsed_files = parsed_files.select do |h|
    h[:test][:title].line_and_column[0] == line_number.to_i
  end
end

parsed_files.each do |parse_tree|
  builder = MudInEveryLanguage::Spec::Builder.new(server)
  TestTransformer.new.apply(parse_tree, builder: builder)
end
