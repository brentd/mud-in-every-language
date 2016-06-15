module Helpers
  def expect_displayed(text)
    expect(@client).to display(text)
  end
end

RSpec::Matchers.define :display do |expected|
  match do |actual|
    result = actual.readlines_until do |line|
      values_match? expected, line
    end
    @actual = actual.log.join("\n")
    result
  end

  diffable
end
