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

project = MudInEveryLanguage::Project.new(ARGV[0] || ".")

server = TestServer.new(
  project_dir:  project.dir,
  port:         ENV["MUD_PORT"] || 6000,
  command:      project.settings["start"],
  # log:          STDOUT
)

spec_dir = File.expand_path("../../spec", __FILE__)

if ARGV[1]
  file, line_number = ARGV[1].split(":")
end

parsed_files = begin
  if file
    parse_tree = TestParser.new.parse_with_debug(File.read(file))

    if line_number
      idx = parse_tree.index { |h| line_number.to_i < h[:test][:title].line_and_column[0] }
      parse_tree = parse_tree[(idx || parse_tree.size) - 1]
    end

    [[file, parse_tree]]
  else
    Dir["#{spec_dir}/*_test"].map do |f|
      [f, TestParser.new.parse_with_debug(File.read(f))]
    end
  end
end


parsed_files.each do |(filename, tree)|
  builder = MudInEveryLanguage::Spec::Builder.new(server, filename)
  TestTransformer.new.apply(tree, builder: builder)
end
