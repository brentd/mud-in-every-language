require "parslet"
require "minitest/autorun"

class TestParser < Parslet::Parser
  rule(:rest_of_line)  { match('[^\n]').repeat(1) }
  rule(:newline)       { str("\n") }
  rule(:title)         { rest_of_line.as(:title) >> newline }
  rule(:prefix)        { match('%|>').as(:prefix) >> str(" ").repeat(1) }
  rule(:indented_line) { (str("  ") >> prefix.maybe >> rest_of_line.as(:text)) >> newline }
  rule(:test)          { (title >> indented_line.repeat.as(:lines)).as(:test) >> newline.repeat }
  rule(:tests)         { test.repeat.as(:tests) }

  root(:tests)
end

class TestLine < Struct.new(:slice)
  def to_s
    slice.to_s
  end

  def to_str
    to_s
  end

  def quoted
    to_s.inspect
  end
end

class AssertionLine < TestLine; end
class InputLine < TestLine; end
class RubyLine < TestLine; end

class TestTransformer < Parslet::Transform
  rule(prefix: simple(:prefix), text: simple(:text)) do
    case prefix
    when ">"
      InputLine.new(text)
    when "%"
      RubyLine.new(text)
    end
  end

  rule(text: simple(:text)) do
    AssertionLine.new(text)
  end

  rule(title: simple(:title), lines: sequence(:lines)) do
    test_lines = lines

    spec.it(title) do
      fail
    end


    # test_lines = lines
    # group.it(title) do
      # test_lines.each do |line|
      #   eval_str = case line
      #     when AssertionLine
      #       "expect(client).to display(#{line.quoted})"
      #     when InputLine
      #       "client << #{line.quoted}"
      #     when RubyLine
      #       line
      #   end
      #   instance_eval(eval_str, "spec/login_test", line.slice.line_and_column.first)
      # end
    # end
  end
end


parse_tree = begin
  TestParser.new.parse(File.read("spec/login_test"))
rescue Parslet::ParseFailed => e
  puts e.cause.ascii_tree
end

# group = RSpec.describe("login_test")
# group.metadata[:rerun_file_path] = "spec/login_test"
TestTransformer.new.apply(parse_tree, spec: Class.new(MiniTest::Spec))

# RSpec::Core::Runner.invoke
