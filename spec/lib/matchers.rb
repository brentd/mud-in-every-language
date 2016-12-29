module Helpers
  extend RSpec::SharedContext

  let(:client) do
    TestClient.new(
      log: @log,
      port: $settings["port"]
    )
  end

  def » text
    expect(client).to display(text)
  end

  def « input
    client << input
    sleep 0.01
  end
end

RSpec::Matchers.define :display do |expected|
  match do |client|
    log     = StringIO.new
    matched = false
    timeout = 2

    reader = Thread.new do
      client.each do |line|
        matched = values_match?(expected, line.rstrip)
        log << matched ? line.green : line
        break if matched
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
