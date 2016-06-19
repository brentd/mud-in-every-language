module Helpers
  def expect_displayed(text)
    expect(@client).to display(text)
  end
end

RSpec::Matchers.define :display do |expected|
  match do |client|
    log     = StringIO.new
    matched = false
    timeout = 2

    reader = Thread.new do
      client.each_line do |line|
        log << line
        break if matched = values_match?(expected, line.rstrip)
      end
    end

    begin
      reader.abort_on_exception = true
      reader.join(timeout)
    ensure
      reader.kill
    end

    @actual = log.string
    matched
  end

  diffable
end
