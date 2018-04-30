require "pathname"
require "yaml"
require "parslet"
require "pry"

# The parse turns raw text into a tree of string tokens. Read it from the bottom up.
class TestParser < Parslet::Parser
  rule(:rest_of_line)  { match('[^\n]').repeat(1) }
  rule(:newline)       { str("\n") }

  rule(:title)         { rest_of_line.as(:title) >> newline }
  rule(:prefix)        { match('%|>').as(:prefix) >> str(" ") }
  rule(:indented_line) { str("  ") >> prefix.maybe >> rest_of_line.as(:line) >> newline }
  rule(:test)          { title >> indented_line.repeat.as(:lines) >> newline.repeat }
  rule(:tests)         { test.as(:test).repeat }

  root(:tests)
end

# The transformer walks the parse tree of string tokens and turns them into
# meaningful objects.
class TestTransformer < Parslet::Transform
  rule(prefix: simple(:prefix), line: simple(:line)) do
    case prefix
    when ">"
      InputLine.new(line)
    when "%"
      RubyLine.new(line)
    end
  end

  rule(line: simple(:line)) do
    AssertionLine.new(line)
  end

  rule(test: {title: simple(:title), lines: sequence(:lines)}) do
    builder.call(title, lines)
  end
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

  def location
    slice.line_and_column.first
  end
end

class AssertionLine < TestLine; end
class InputLine < TestLine; end
class RubyLine < TestLine; end
